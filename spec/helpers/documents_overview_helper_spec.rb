require 'rails_helper'

RSpec.describe DocumentsOverviewHelper do
  context "for a known document type" do
    let(:document_type) { "W-2" }

    it "returns the correct path" do
      result = helper.edit_document_path(document_type)
      expect(result).to eq("/documents/w2s")
    end
  end

  context "for an unknown document type" do
    let(:document_type) { "AnOldPieceOfParchment" }

    it "raises an error" do
      expect { helper.edit_document_path(document_type) }
        .to raise_error(/Missing/)
    end
  end
end
