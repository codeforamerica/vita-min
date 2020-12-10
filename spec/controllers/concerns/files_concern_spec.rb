require "rails_helper"

RSpec.describe FilesConcern, type: :controller do

  controller(ApplicationController) do
    include FilesConcern
  end

  let(:attachment) { double }

  describe "#transient_storage_url" do
    let(:redirect_url) { "https://gyr-demo.s3.amazonaws.com/file.png?sig=whatever&expires=whatever" }

    before do
      allow(attachment).to receive(:service_url).and_return(redirect_url)
    end

    it "calls #service_url when given a blob" do
      expect(subject.transient_storage_url(attachment)).to eq(redirect_url)
      expect(attachment).to have_received(:service_url).with(disposition: :inline)
    end

    it "passes the optional disposition parameter" do
      expect(subject.transient_storage_url(attachment, disposition: "attachment")).to eq(redirect_url)
      expect(attachment).to have_received(:service_url).with(disposition: "attachment")
    end
  end
end
