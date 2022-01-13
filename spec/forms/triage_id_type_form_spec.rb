require "rails_helper"

RSpec.describe TriageIdTypeForm do
  describe "validations" do
    it "requires id_type" do
      form = described_class.new(nil, {})
      expect(form).not_to be_valid
      expect(form.errors).to include :id_type
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:params) do
        { "id_type": "have_paperwork" }
      end
      let(:triage) { create(:triage, id_type: nil) }

      it "saves the data" do
        described_class.new(triage, params).save
        expect(triage.reload.id_type).to eq("have_paperwork")
      end
    end
  end
end
