require "rails_helper"

RSpec.describe Navigation::StateFileBaseQuestionNavigation do
  describe "self.show_progress?" do
    it "returns default of true" do
      expect(described_class.show_progress?(Class.new)).to eq(true)
    end
  end
end
