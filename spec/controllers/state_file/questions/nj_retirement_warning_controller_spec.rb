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

      context "when the intake contains a yes/no value for eligibility_retirement_warning_continue" do
        before do
          intake.eligibility_retirement_warning_continue = :yes
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
        end
        it "does not modify the value to shown" do
          expect(described_class.show?(intake)).to eq true
          expect(intake.eligibility_retirement_warning_continue).to eq("yes")
        end
      end

      context "when the helper decides no income warning should be shown" do
        it "does not show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(false)
          expect(described_class.show?(intake)).to eq false
          expect(intake.eligibility_retirement_warning_continue).to eq("unfilled")
        end
      end
  
      context "when the helper decides a income warning should be shown" do
        before do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
        end

        it "does show" do
          expect(described_class.show?(intake)).to eq true
        end

        it "updates eligibility_retirement_warning_continue" do
          expect {
            get :edit
          }.to change { intake.reload.eligibility_retirement_warning_continue }.from("unfilled").to("shown")
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
          expect(intake.eligibility_retirement_warning_continue).to eq("unfilled")
        end
      end
  
      context "when the helper decides a income warning should be shown" do
        it "does NOT show" do
          allow_any_instance_of(Efile::Nj::NjRetirementIncomeHelper).to receive(:show_retirement_income_warning?).and_return(true)
          expect(described_class.show?(intake)).to eq false
          expect(intake.eligibility_retirement_warning_continue).to eq("unfilled")
        end
      end
    end
  end
end
