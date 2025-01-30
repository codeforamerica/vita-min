require "rails_helper"

RSpec.describe StateFile::MdRetirementIncomeSubtractionForm do

  describe "#save" do
    let(:state_file_md1099_r_followup) { create :state_file_md1099_r_followup }

    let(:form) { described_class.new(state_file_md1099_r_followup, params) }

    context "validations" do
      context "with invalid parameters" do
        let(:params) { {} }
        it "returns false and adds an error to the form" do
          expect(form.valid?).to eq false
          expect(form.errors).to include(:income_source, :service_type)
        end
      end

      context "with valid parameters" do
        let(:params) {
          {
            income_source: "pension_annuity_endowment",
            service_type: "military"
          }
        }

        it "returns true and updates the intake" do
          expect(form.valid?).to eq true
          form.save
          state_file_md1099_r_followup.reload
          expect(state_file_md1099_r_followup).to be_income_source_pension_annuity_endowment
          expect(state_file_md1099_r_followup).to be_service_type_military
        end
      end
    end
  end
end


