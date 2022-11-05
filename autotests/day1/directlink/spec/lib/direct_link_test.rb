require 'spec_helper'
require_relative "../../lib/directlink"
require 'webmock/rspec'

describe DirectLink do
  context "when link is imgur" do
    before(:all) do
      @valid_imgur_url = "https://imgur.com/8IX7Mp9"

      stub_request(:get, /\.png\z/).to_return body: "GIF89a\x01\x00\x01\x00\x00\xff\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x00"
    end

    it "when valid imgur url" do
      expect(DirectLink.new(@valid_imgur_url).call).to eq(["#{@valid_imgur_url}.png", 1, 1, :gif])
    end
  end

  context "when link is old.reddit" do
    before(:all) do
      @valid_imgur_url = "https://imgur.com/8IX7Mp9"
      @valid_old_reddit_url = "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original"
      json = [{"data"=> {"children"=> ["data"=> { "url_overridden_by_dest"=>@valid_imgur_url}]}}]

      stub_request(:get, "#{@valid_old_reddit_url}.json").
        with(
          headers: {
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: json, headers: {})

      stub_request(:get, @valid_imgur_url).
        with(
          headers: {
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "GIF89a\x01\x00\x01\x00\x00\xff\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x00", headers: {})
    end

    it "when valid imgur url" do
      expect(DirectLink.new(@valid_old_reddit_url).call).to eq([@valid_imgur_url, 1, 1, :gif])
    end
  end
end
