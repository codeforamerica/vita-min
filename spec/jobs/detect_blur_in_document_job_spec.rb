require 'rails_helper'

RSpec.describe DetectBlurInDocumentJob do
  describe "#perform" do
    context "when provided an image document" do
      let(:document) { create(:document) }

      it "updates score on document" do
        expect {
          described_class.perform_now(document: document)
        }.to change(document, :blur_score)
      end
    end
  end
end
