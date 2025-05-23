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
        expect(response.body).to include(I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_same_home_spouse"))
      end
    end

    context "when a user is not MFS" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }

      it "does not show the tenant_same_home_spouse checkbox" do
        get :edit
        expect(response.body).not_to include(I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_same_home_spouse"))
      end
    end
  end

  describe "#prev_path" do
    it "routes to household_rent_own" do
      expect(subject.prev_path).to eq(StateFile::Questions::NjHouseholdRentOwnController.to_path_helper)
    end
  end

  describe "#next_path" do
    context "when ineligible" do
      context "when income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: "rent",
            tenant_home_subject_to_property_taxes: "no"
          )
        }
        it "next path is ineligible page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper + "?on_home_or_rental=rental")
        end
      end

      context "when not eligible for property tax deduction but could be for credit" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_disabled,
            household_rent_own: "rent",
            tenant_home_subject_to_property_taxes: "no"
          )
        }
        it "next path is ineligible page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper + "?on_home_or_rental=rental")
        end
      end
    end

    context "when advance state" do
      context "when income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: "rent",
            tenant_home_subject_to_property_taxes: "yes"
          )
        }
        it "next path is rent paid page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjTenantRentPaidController.to_path_helper)
        end
      end
      
      context "when not eligible for property tax deduction but could be for credit" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_disabled,
            household_rent_own: "rent",
            tenant_home_subject_to_property_taxes: "yes"
          )
        }
        it "next path is next_controller for property tax flow" do
          expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowOffRamp.next_controller({}))
        end
      end
    end
  end
end
