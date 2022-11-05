require 'spec_helper'
require "open3"

describe "./bin/directlink" do
  let(:valid_imgur_url) { "https://imgur.com/8IX7Mp9" }
  let(:valid_old_reddit_url) { "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original/" }
  let(:valid_reddit_image_url) { "https://i.redd.it/ic0t7aw7g1n41.jpg" }

  let(:invalid_umgur_url) { "https://imgur.com/a/badlinkpattern" }
  let(:invalid_reddit_url) { "https://old.reddit.com/r/badurl/" }
  let(:invalid_url) { "test" }
  let(:unknown_url) { "http://google.com" }

  let(:popen) {  ->(input) { Open3.capture2e "./bin/directlink #{input.shellescape}" } }

  context "when imgur link" do
    context "when link is valid" do
      it "shows valid output" do
        string, status = popen[valid_imgur_url]

        valid_response =
          <<~HEREDOC
            <= #{valid_imgur_url}
            => #{valid_imgur_url}.png
               png 720x537
          HEREDOC

        expect([string, status.exitstatus]).to eq([valid_response, 0])
      end
    end

    context "when link is not valid" do
      it "show message \"bad link\"" do
        string, status = popen[invalid_umgur_url]

        expect(status.exitstatus).to eq(1)
        expect(string).to include("bad link\n")
      end
    end

    context "when link is broken" do
      it "show message \"bad link\"" do
        string, status = popen[invalid_url]

        expect(status.exitstatus).to eq(1)
        expect(string).to include("bad link\n")
      end
    end
  end

  context "when link is old.reddit" do
    context "when link is valid" do
      it "shows valid output" do
        string, status = popen[valid_old_reddit_url]

        valid_response =
          <<~HEREDOC
            <= #{valid_old_reddit_url}
            => #{valid_reddit_image_url}
               jpeg 720x537
        HEREDOC

        expect([string, status.exitstatus]).to eq([valid_response, 0])
      end
    end

    context "when link is not valid" do
      it "show message \"bad link\"" do
        string, status = popen[invalid_url]

        expect(status.exitstatus).to eq(1)
        expect(string).to include("bad link\n")
      end
    end
  end

  context "when link is unknown" do
    it "show message \"bad link\"" do
      string, status = popen[unknown_url]

      expect(status.exitstatus).to eq(1)
      expect(string).to include("bad link\n")
    end
  end
end
