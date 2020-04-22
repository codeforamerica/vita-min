require "rails_helper"

RSpec.describe DocumentsHelper do
  describe "#must_have?" do
    context "a document that the user has already uploaded" do
      let(:doc_type) { "SSN or ITIN" }

      it "returns false" do
        expect(helper.must_have?(doc_type)).to eq false
      end
    end

    context "a document that we can be sure someone needs" do
      let(:doc_type) { "1095-A" }

      it "returns true" do
        expect(helper.must_have?(doc_type)).to eq true
      end
    end

    context "a document that we cannot be sure someone needs" do
      let(:doc_type) { "1099-DIV" }

      it "returns false" do
        expect(helper.must_have?(doc_type)).to eq false
      end
    end
  end

  describe "#might_have?" do
    context "a document that the user has already uploaded" do
      let(:doc_type) { "SSN or ITIN" }

      it "returns false" do
        expect(helper.must_have?(doc_type)).to eq false
      end
    end

    context "a document that we can be sure someone needs" do
      let(:doc_type) { "1095-A" }

      it "returns true" do
        expect(helper.might_have?(doc_type)).to eq false
      end
    end

    context "a document that we cannot be sure someone needs" do
      let(:doc_type) { "1099-DIV" }

      it "returns false" do
        expect(helper.might_have?(doc_type)).to eq true
      end
    end
  end

  describe "#any_might_have_docs?" do
    context "a person whose recommended document types include some they might have" do
      let(:doc_types) { ["1099-MISC", "W-2"] }

      it "returns true" do
        expect(helper.any_might_have_docs?(doc_types)).to eq true
      end
    end

    context "a person whose recommended document types do not include any they might have" do
      let(:doc_types) { ["1095-A"] }

      it "returns true" do
        expect(helper.any_might_have_docs?(doc_types)).to eq false
      end
    end
  end

  describe "#any_must_have_docs?" do
    context "a person whose recommended document types include some they must have" do
      let(:doc_types) { ["1099-R"] }

      it "returns true" do
        expect(helper.any_must_have_docs?(doc_types)).to eq true
      end
    end

    context "a person whose recommended document types do not include any they must have" do
      let(:doc_types) { ["1099-MISC", "W-2"] }

      it "returns true" do
        expect(helper.any_must_have_docs?(doc_types)).to eq false
      end
    end
  end
end
