require "rails_helper"

RSpec.describe QuestionNavigation do
  before(:each) do
    class BaseController
      def self.show?(_)
        true
      end

      def current_intake; end
    end

    class FirstController < BaseController; end
    class SecondController < BaseController; end
    class ThirdController < BaseController; end

    stub_const("QuestionNavigation::FLOW",
      [
        FirstController,
        SecondController,
        ThirdController,
      ]
    )
  end

  describe ".controllers" do
    it "returns the main flow" do
      expect(QuestionNavigation.controllers).to match_array(
        [
           FirstController,
           SecondController,
           ThirdController,
        ],
      )
    end
  end

  describe ".first" do
    it "delegates to .controllers" do
      expect(QuestionNavigation.first).to eq(FirstController)
    end
  end

  describe "#next" do
    context "when current controller is second to last or before" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns numeric index for next non-skipped controller in main flow" do
        navigation = QuestionNavigation.new(FirstController.new)
        expect(navigation.next).to eq(ThirdController)
      end
    end

    context "when current controller is the last" do
      it "returns nil" do
        navigation = QuestionNavigation.new(ThirdController.new)
        expect(navigation.next).to be_nil
      end
    end
  end
end
