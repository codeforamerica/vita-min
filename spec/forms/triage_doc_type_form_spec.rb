require "rails_helper"

RSpec.describe TriageDocTypeForm do
  describe "validations" do
    it "requires doc_type" do
      form = described_class.new(nil, {})
      expect(form).not_to be_valid
      expect(form.errors).to include(:doc_type)
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        {
          doc_type: "all_copies",
        }
      end
      let(:triage) { create(:triage) }

      it "saves the data" do
        described_class.new(triage, params).save
        expect(triage.reload.doc_type).to eq("all_copies")
      end
    end
  end
end
