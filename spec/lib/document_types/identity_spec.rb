require "rails_helper"

describe "DocumentTypes::Identity" do
  describe '.provides_doc_help?' do
    it 'is true' do
      expect(DocumentTypes::Identity.provide_doc_help?).to eq true
    end
  end
end