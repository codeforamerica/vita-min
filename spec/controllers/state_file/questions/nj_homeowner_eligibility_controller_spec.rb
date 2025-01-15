require "rails_helper"

RSpec.describe StateFile::Questions::NjHomeownerEligibilityController do
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

    context "when a user is a homeowner" do
      let(:form_params) {
        {
          state_file_nj_homeowner_eligibility_form: {
            homeowner_home_subject_to_property_taxes: :yes,
            homeowner_more_than_one_main_home_in_nj: :no,
            homeowner_shared_ownership_not_spouse: :yes,
            homeowner_same_home_spouse: :yes,
          }
        }
      }

      it "saves the checkbox selections" do
        post :update, params: form_params

        intake.reload
        expect(intake.homeowner_home_subject_to_property_taxes).to eq "yes"
        expect(intake.homeowner_more_than_one_main_home_in_nj).to eq "no"
        expect(intake.homeowner_shared_ownership_not_spouse).to eq "yes"
        expect(intake.homeowner_same_home_spouse).to eq "yes"
      end
    end

    context "when a user is MFS" do
      let(:intake) { create :state_file_nj_intake, :df_data_mfs }

      it "shows the homeowner_same_home_spouse checkbox" do
        get :edit
        expect(response.body).to include(I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_same_home_spouse"))
      end
    end

    context "when a user is not MFS" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }

      it "does not show the homeowner_same_home_spouse checkbox" do
        get :edit
        expect(response.body).not_to include(I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_same_home_spouse"))
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
            household_rent_own: "own",
            homeowner_home_subject_to_property_taxes: "no"
          )
        }
        it "next path is ineligible page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper + "?on_home_or_rental=home")
        end
      end
      
      context "when not eligible for property tax deduction but could be for credit" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_disabled,
            household_rent_own: "own",
            homeowner_home_subject_to_property_taxes: "no"
          )
        }
        it "next path is ineligible page with on_home_or_rental param set to home" do
          expect(subject.next_path).to eq(StateFile::Questions::NjIneligiblePropertyTaxController.to_path_helper + "?on_home_or_rental=home")
        end
      end
    end

    context "when worksheet required" do
      context "when income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: "own",
            homeowner_more_than_one_main_home_in_nj: "yes"
          )
        }
        it "next path is homeowner worksheet page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerPropertyTaxWorksheetController.to_path_helper)
        end
      end

      context "when not eligible for property tax deduction but could be for credit" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_disabled,
            household_rent_own: "own",
            homeowner_more_than_one_main_home_in_nj: "yes"
          )
        }
        it "moves to next_controller from property tax flow" do
          expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowOffRamp.next_controller({}))
        end
      end
    end

    context "when advance state" do
      context "when income above property tax minimum" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: "own",
            homeowner_home_subject_to_property_taxes: "yes"
          )
        }
        it "next path is property tax page" do
          expect(subject.next_path).to eq(StateFile::Questions::NjHomeownerPropertyTaxController.to_path_helper)
        end
      end
      
      context "when not eligible for property tax deduction but could be for credit" do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_disabled,
            household_rent_own: "own",
            homeowner_home_subject_to_property_taxes: "yes"
          )
        }
        it "next path is next_controller for property tax flow" do
          expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowOffRamp.next_controller({}))
        end
      end
    end
  end
end
