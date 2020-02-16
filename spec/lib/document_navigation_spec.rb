require "rails_helper"

RSpec.describe DocumentNavigation do
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

    class ExternalController; end

    stub_const(
      "DocumentNavigation::DOCUMENT_CONTROLLERS",
      {
        "Doc-1" => FirstController,
        "Doc-2" => SecondController,
        "Doc-3" => ThirdController,
      }
    )
    stub_const("DocumentNavigation::GENERIC_CONTROLLERS", [])
  end

  describe ".controllers" do
    it "returns the ordered controllers" do
      expect(described_class.controllers).to match_array(
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
      expect(described_class.first).to eq(FirstController)
    end
  end

  describe ".document_type" do
    it "returns the document type string corresponding to the given controller" do
      expect(described_class.document_type(SecondController)).to eq "Doc-2"
    end
  end

  describe "#next" do
    context "when current controller is second to last or before" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns numeric index for next non-skipped controller in main flow" do
        navigation = described_class.new(FirstController.new)
        expect(navigation.next).to eq(ThirdController)
      end
    end

    context "when current controller is the last" do
      it "returns nil" do
        navigation = described_class.new(ThirdController.new)
        expect(navigation.next).to be_nil
      end
    end
  end

  describe "#first_for_intake" do
    let(:intake) { build :intake }
    before do
      allow(FirstController).to receive(:show?) { false }
    end

    it "returns the first relevant controller for the given input" do
      navigation = described_class.new(ExternalController.new)
      expect(navigation.first_for_intake(intake)).to eq SecondController
    end
  end

  describe "#select" do
    let(:intake) { build :intake }
    before do
      allow(SecondController).to receive(:show?) { false }
    end

    it "returns an array of all controllers that should be displayed for the current intake" do
      navigation = described_class.new(ThirdController.new)
      expect(navigation.select(intake)).to eq [FirstController, ThirdController]
    end
  end

  describe "#types_for_intake" do
    let(:intake) { build :intake }
    before do
      allow(SecondController).to receive(:show?) { false }
    end

    it "returns an array of all document types that should be displayed for the current intake" do
      navigation = described_class.new(ThirdController.new)
      expect(navigation.types_for_intake(intake)).to eq ["Doc-1", "Doc-3"]
    end
  end
end
