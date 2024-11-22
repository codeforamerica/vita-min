require 'rails_helper'

describe StateFile::Questions::NjCollegeDependentsExemptionController do
  let(:intake) { create :state_file_nj_intake }

  before do
    sign_in intake
  end

  describe "#show?" do
    let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
    let(:first_dependent) { intake.dependents[0] }
    let(:second_dependent) { intake.dependents[1] }

    context "when dependents under 22 exist" do
      before do
        current_year = MultiTenantService.statefile.current_tax_year
        intake.dependents[0].update(dob: Date.new(current_year - 22, 12, 31)) # Kronos is 22
        intake.dependents[1].update(dob: Date.new(current_year - 21, 1, 1)) # Aphrodite is 21
      end

      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when no dependents are under 22" do
      before do
        current_year = MultiTenantService.statefile.current_tax_year
        intake.dependents[0].update(dob: Date.new(current_year - 22, 12, 31)) # Kronos is 22
        intake.dependents[1].update(dob: Date.new(current_year - 22, 1, 1)) # Aphrodite is 22
      end

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when no dependents exist" do
      let(:intake) { create :state_file_nj_intake, :df_data_minimal }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    render_views
    it "succeeds" do
      get :edit
      expect(response).to be_successful
    end

    context "when dependents under 22 exist" do
      let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
      let(:first_dependent) { intake.dependents[0] }
      let(:second_dependent) { intake.dependents[1] }

      let(:form_params) {
        {
          state_file_nj_college_dependents_exemption_form: {
            dependents_attributes: {
              '0': {
                id: first_dependent.id,
                nj_dependent_attends_accredited_program: "yes",
                nj_dependent_enrolled_full_time: "no",
                nj_dependent_five_months_in_college: "no",
                nj_filer_pays_tuition_for_dependent: "yes"
              },
              '1': {
                id: second_dependent.id,
                nj_dependent_attends_accredited_program: "yes",
                nj_dependent_enrolled_full_time: "yes",
                nj_dependent_five_months_in_college: "yes",
                nj_filer_pays_tuition_for_dependent: "no"
              }
            }
          }
        }
      }

      before do
        current_year = MultiTenantService.statefile.current_tax_year
        intake.dependents[0].update(dob: Date.new(current_year - 22, 12, 31)) # Kronos is 22
        intake.dependents[1].update(dob: Date.new(current_year - 21, 1, 1)) # Aphrodite is 21
      end

      it "saves the checkbox selections" do
        post :update, params: form_params

        intake.reload
        expect(intake.dependents[0].nj_dependent_attends_accredited_program).to eq "yes"
        expect(intake.dependents[0].nj_dependent_enrolled_full_time).to eq "no"
        expect(intake.dependents[0].nj_dependent_five_months_in_college).to eq "no"
        expect(intake.dependents[0].nj_filer_pays_tuition_for_dependent).to eq "yes"

        expect(intake.dependents[1].nj_dependent_attends_accredited_program).to eq "yes"
        expect(intake.dependents[1].nj_dependent_enrolled_full_time).to eq "yes"
        expect(intake.dependents[1].nj_dependent_five_months_in_college).to eq "yes"
        expect(intake.dependents[1].nj_filer_pays_tuition_for_dependent).to eq "no"
      end

      it "only shows dependents under age 22 (born on or after 1/1/2003 for 2024)" do
        get :edit
        expect(response.body).to include("Aphrodite")
        expect(response.body).not_to include("Kronos")
      end
    end
  end
end
