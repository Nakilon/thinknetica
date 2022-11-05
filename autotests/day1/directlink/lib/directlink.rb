require "fastimage"
require "faraday"

class DirectLink
  attr_reader :link

  class ErrorBadLink < RuntimeError ; end

  def initialize(link)
    @link = link
  end

  def call
    host = URI(link).host

    unless host
      raise ErrorBadLink.new(link)
    end

    case host.split(?.).last(2)
    when %w{ imgur com }
      imgur
    when %w{ reddit com }
      reddit
    else
      raise ErrorBadLink.new(link)
    end
  end

  private

  def imgur
    case link
    when /\Ahttps?:\/\/imgur\.com\/([a-zA-Z0-9]+)\z/
      f = FastImage.new("#{link}.png")
      ["#{link}.png", *f.size, f.type]
    else
      raise ErrorBadLink.new link
    end
  end

  def reddit
    case link
    when /^https?:\/\/old\.reddit\.com([\w\/]*)$/
      actual_json_link = link[".json"] ? link : "#{link}.json"
      response = make_request(actual_json_link)
      link_image = response.dig(0, "data", "children", 0, "data", "url_overridden_by_dest")

      unless link_image
        raise ErrorBadLink.new(link)
      end

      f = FastImage.new(link_image)
      [link_image, *f.size, f.type]
    else
      raise ErrorBadLink.new(link)
    end
  end

  def make_request(actual_link)
    conn = Faraday.new(url: actual_link) do |faraday|
      faraday.response(:json)
      faraday.request(:json)
    end

    response = conn.get("") do |request|
      request.headers = { 'User-Agent' => 'Ruby' }
    end

    response.body
  end
end
