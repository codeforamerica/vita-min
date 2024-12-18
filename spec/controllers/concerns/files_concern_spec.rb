require "rails_helper"

RSpec.describe FilesConcern, type: :controller do

  controller(ApplicationController) do
    include FilesConcern
  end

  let(:attachment) { double }

  describe "#transient_storage_url" do
    let(:rspec_redirect_url) { "https://some-fake-s3-bucket-url.com/document.pdf?sig=whatever&expires=whatever" }

    before do
      allow(attachment).to receive(:url).and_return(rspec_redirect_url)
    end

    it "calls #url when given a blob" do
      expect(subject.transient_storage_url(attachment)).to eq(rspec_redirect_url)
      expect(attachment).to have_received(:url).with(disposition: :inline)
    end

    it "passes the optional disposition parameter" do
      expect(subject.transient_storage_url(attachment, disposition: "attachment")).to eq(rspec_redirect_url)
      expect(attachment).to have_received(:url).with(disposition: "attachment")
    end
  end
end
