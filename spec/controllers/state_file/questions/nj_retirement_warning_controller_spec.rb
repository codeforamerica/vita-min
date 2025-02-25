require "rails_helper"

RSpec.describe StateFile::Questions::NjRetirementWarningController do
  describe ".show?" do
    let (:intake) { create :state_file_nj_intake }
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
end
