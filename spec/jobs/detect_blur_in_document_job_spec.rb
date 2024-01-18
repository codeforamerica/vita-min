require 'rails_helper'

RSpec.describe DetectBlurInDocumentJob do
  describe "#perform" do
    xcontext "when provided an image document" do
      let(:document) { create(:document) }

      it "updates score on document" do
        expect {
          described_class.perform_now(document: document)
        }.to change(document, :blur_score)
      end
    end

    xcontext "when provided a PDF document" do
      let(:document) { create(:document, :pdf) }

      it "does not update score on document" do
        expect {
          described_class.perform_now(document: document)
        }.not_to change(document, :blur_score)
      end
    end
  end
end
