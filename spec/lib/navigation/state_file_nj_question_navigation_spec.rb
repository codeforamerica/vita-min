require "rails_helper"

RSpec.describe Navigation::StateFileNjQuestionNavigation do
  describe "self.show_progress?" do
    context "screen that should not show the progress bar" do
      let(:controller_class) { StateFile::Questions::EligibleController }
      it "returns false" do
        expect(described_class.show_progress?(controller_class)).to eq(false)
      end
    end

    context "screen that should show the progress bar" do
      let(:controller_class) { StateFile::Questions::IncomeReviewController }
      it "returns true" do
        expect(described_class.show_progress?(controller_class)).to eq(true)
      end
    end
  end
end
