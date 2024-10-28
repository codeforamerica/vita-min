require "rails_helper"

RSpec.describe StateFile::Questions::NjTenantEligibilityController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "when a user is a tenant" do
      let(:form_params) {
        {
          state_file_nj_tenant_eligibility_form: {
            tenant_home_subject_to_property_taxes: :yes,
            tenant_shared_rent_not_spouse: :no,
            tenant_same_home_spouse: :yes,
          }
        }
      }

      it "saves the checkbox selections" do
        post :update, params: form_params

        intake.reload
        expect(intake.tenant_home_subject_to_property_taxes).to eq "yes"
        expect(intake.tenant_shared_rent_not_spouse).to eq "no"
        expect(intake.tenant_same_home_spouse).to eq "yes"
      end
    end

    context "when a user is MFS" do
      let(:intake) { create :state_file_nj_intake, :df_data_mfs }

      it "shows the tenant_same_home_spouse checkbox" do
        get :edit
        expect(response.body).to include("Did you and your spouse live in the same home?")
      end
    end

    context "when a user is not MFS" do
      let(:intake) { create :state_file_nj_intake, :df_data_mfj }

      it "does not show the tenant_same_home_spouse checkbox" do
        get :edit
        expect(response.body).not_to include("Did you and your spouse live in the same home?")
      end
    end
  end

  describe "#show?" do
    context "when indicated that they rent" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when indicated that they own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated neither rent nor own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated both rent and own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#next_path" do
    context "when ineligible hard no" do
      let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "no" }
      it "next path is ineligible page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper)
      end
    end

    context "when unsupported soft no" do
      let(:intake) { create :state_file_nj_intake, tenant_more_than_one_main_home_in_nj: "yes" }
      it "next path is unsupported page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjUnsupportedPropertyTaxController.to_path_helper)
      end
    end

    context "when advance state" do
      let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "yes" }
      it "next path is rent paid page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjTenantRentPaidController.to_path_helper)
      end
    end
  end
end

