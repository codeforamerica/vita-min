require "rails_helper"

RSpec.describe ControllerNavigation do
  class ConcernedWithControllerNavigation
    include ControllerNavigation
  end
  let(:navigation_class) { ConcernedWithControllerNavigation }
  before do
    class BaseController
      def self.show?(_)
        true
      end

      def self.model_for_show_check(controller)
        controller.visitor_record
      end

      def visitor_record; end
    end

    class FirstController < BaseController; end
    class SecondController < BaseController; end
    class ThirdController < BaseController; end

    stub_const("#{navigation_class.name}::FLOW",
               [
                   FirstController,
                   SecondController,
                   ThirdController,
               ]
    )


  end

  describe ".controllers" do
    it "returns the main flow" do
      expect(navigation_class.controllers).to match_array(
                                                  [
                                                      FirstController,
                                                      SecondController,
                                                      ThirdController,
                                                  ]
                                              )
    end
  end

  describe ".first" do
    it "delegates to .controllers" do
      expect(navigation_class.first).to eq(FirstController)
    end
  end

  describe "#next" do
    context "when current controller is second to last or before" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns numeric index for next non-skipped controller in main flow" do
        navigation = navigation_class.new(FirstController.new)
        expect(navigation.next).to eq(ThirdController)
      end
    end

    context "when current controller is the last" do
      it "returns nil" do
        navigation = navigation_class.new(ThirdController.new)
        expect(navigation.next).to be_nil
      end
    end
  end

  describe "#prev" do
    before do
      allow(SecondController).to receive(:show?) { false }
    end

    it "returns path for next non-skipped controller in main flow" do
      navigation = navigation_class.new(ThirdController.new)
      expect(navigation.prev).to eq(FirstController)
    end

    context "when current controller is the first" do
      it "returns nil" do
        navigation = navigation_class.new(FirstController.new)
        expect(navigation.prev).to be_nil
      end
    end
  end
end
