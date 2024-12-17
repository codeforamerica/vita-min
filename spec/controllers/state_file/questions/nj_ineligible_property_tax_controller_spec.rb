require "rails_helper"

RSpec.describe StateFile::Questions::NjIneligiblePropertyTaxController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#ineligible_reason" do
    describe "reason_property_taxes" do
      context "when homeowner and homeowner_home_subject_to_property_taxes is NO" do
        let(:intake) { create :state_file_nj_intake, homeowner_home_subject_to_property_taxes: "no" }
        it "returns reason_property_taxes text" do
          get :edit, params: {on_home_or_rental: "home"}
          expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_property_taxes")
          expect(subject.ineligible_reason).to eq(expected_text)
        end
      end

      context "when tenant and tenant_home_subject_to_property_taxes is NO" do
        let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "no" }
        it "returns reason_property_taxes text" do
          get :edit, params: {on_home_or_rental: "rental"}
          expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_property_taxes")
          expect(subject.ineligible_reason).to eq(expected_text)
        end
      end
    end

    describe "reason_multi_unit_conditions" do
      context "when homeowner and main_home_multi_unit is YES and main_home_multi_unit_max_four_one_commercial is NO" do
        let(:intake) { create :state_file_nj_intake, homeowner_main_home_multi_unit: "yes", homeowner_main_home_multi_unit_max_four_one_commercial: "no" }
        it "returns reason_multi_unit_conditions text" do
          get :edit, params: {on_home_or_rental: "home"}
          expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_multi_unit_conditions")
          expect(subject.ineligible_reason).to eq(expected_text)
        end
      end

      context "when tenant and tenant_building_multi_unit is YES and tenant_access_kitchen_bath is NO" do
        let(:intake) { create :state_file_nj_intake, tenant_building_multi_unit: "yes", tenant_access_kitchen_bath: "no" }
        it "returns reason_multi_unit_conditions text" do
          get :edit, params: {on_home_or_rental: "rental"}
          expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.reason_multi_unit_conditions")
          expect(subject.ineligible_reason).to eq(expected_text)
        end
      end
    end

    describe "reason_neither" do
      context "when household_rent_own is neither" do
        let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }
        it "returns reason_neither text" do
          get :edit, params: {}
          expected_text = I18n.t(
            "state_file.questions.nj_ineligible_property_tax.edit.reason_neither",
            filing_year: MultiTenantService.statefile.current_tax_year
          )
          expect(subject.ineligible_reason).to eq(expected_text)
        end
      end
    end
  end

  describe "#on_home_or_rental" do
    it "on_home" do
      get :edit, params: {on_home_or_rental: "home"}
      expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.on_home")
      expect(subject.on_home_or_rental).to eq(expected_text)
    end

    it "on_rental" do
      get :edit, params: {on_home_or_rental: "rental"}
      expected_text = I18n.t("state_file.questions.nj_ineligible_property_tax.edit.on_rental")
      expect(subject.on_home_or_rental).to eq(expected_text)
    end

    it "when not provided" do
      get :edit, params: {}
      expect(subject.on_home_or_rental).to eq(nil)
    end
  end

  describe "#next_path" do
    context "when indicated both rent and own and coming from homeowner flow" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "next path is tenant eligibility" do
        get :edit, params: {on_home_or_rental: "home"}
        expect(subject.next_path).to eq(StateFile::Questions::NjTenantEligibilityController.to_path_helper)
      end
    end

    context "when indicated both rent and own and coming from rental flow" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "next path is next_controller for property tax flow" do
        get :edit, params: {on_home_or_rental: "rental"}
        expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowHelper.next_controller({}))
      end
    end

    context "when not both rent and own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "next path is next_controller for property tax flow" do
        expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowHelper.next_controller({}))
      end
    end
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end
end