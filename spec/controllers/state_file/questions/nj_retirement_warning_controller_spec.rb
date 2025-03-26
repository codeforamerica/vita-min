require "rails_helper"

RSpec.describe StateFile::Questions::NjRetirementWarningController do
  let (:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe ".show?" do
    context "when the feature flag for show_retirement_ui is ON" do
      before do
        allow_any_instance_of(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      end

      context "when the helper decides no income warning should be shown" do
        it "does not show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(false)
          expect(described_class.show?(intake)).to eq false
        end
      end
  
      context "when the helper decides a income warning should be shown" do
        it "does show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
          expect(described_class.show?(intake)).to eq true
        end
      end
    end
    
    context "when the feature flag for show_retirement_ui is OFF" do
      before do
        allow_any_instance_of(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false)
      end
      context "when the helper decides no income warning should be shown" do
        it "does NOT show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(false)
          expect(described_class.show?(intake)).to eq false
        end
      end
  
      context "when the helper decides a income warning should be shown" do
        it "does NOT show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
          expect(described_class.show?(intake)).to eq false
        end
      end
    end
  end

  describe "#edit" do
    context "when the controller is shown to the user" do
      before do
        allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
      end
      context "and the existing value for eligibility_retirement_warning_continue is UNFILLED" do
        it "sets eligibility_retirement_warning_continue on the intake to SHOWN" do
          expect {
            get :edit
          }.to change { intake.reload.eligibility_retirement_warning_continue }.from("unfilled").to("shown")
        end
      end

      context "and the existing value for eligibility_retirement_warning_continue is YES" do
        before do
          intake.update(eligibility_retirement_warning_continue: :yes)
        end
        it "does not modify the intake attribute to SHOWN" do
          expect {
            get :edit
          }.to not_change { intake.reload.eligibility_retirement_warning_continue }
        end
      end

      context "and the existing value for eligibility_retirement_warning_continue is NO" do
        before do
          intake.update(eligibility_retirement_warning_continue: :no)
        end
        it "does not modify the intake attribute to SHOWN" do
          expect {
            get :edit
          }.to not_change { intake.reload.eligibility_retirement_warning_continue }
        end
      end
    end
  end

  describe "eligibility_offboarding_concern" do
    it_behaves_like :eligibility_offboarding_concern, intake_factory: :state_file_nj_intake do
      let(:eligible_params) do
        {
          state_file_nj_retirement_warning_form: {
            eligibility_retirement_warning_continue: "yes",
          }
        }
      end

      let(:ineligible_params) do
        {
          state_file_nj_retirement_warning_form: {
            eligibility_retirement_warning_continue: "no",
          }
        }
      end
    end
  end
end
