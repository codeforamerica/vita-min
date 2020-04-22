require "rails_helper"


RSpec.describe DocumentNavigation do
  class Documents::FirstController < Documents::DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Doc-1'.freeze
    def self.show?(_); true; end
    def current_intake; end
  end

  class Documents::SecondController < Documents::DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Doc-2'.freeze
    def self.show?(_); true; end
    def current_intake; end
  end

  class Documents::ThirdController < Documents::DocumentUploadQuestionController
    DOCUMENT_TYPE = 'Doc-3'.freeze
    def self.show?(_); true; end
    def current_intake; end
  end

  before(:each) do
    class ExternalController; end

    stub_const(
      "DocumentNavigation::DOCUMENT_CONTROLLERS",
      [
        Documents::FirstController,
        Documents::SecondController,
        Documents::ThirdController,
      ]
    )
    stub_const("DocumentNavigation::BEFORE_CONTROLLERS", [])
    stub_const("DocumentNavigation::AFTER_CONTROLLERS", [])
  end

  describe ".controllers" do
    it "returns the ordered controllers" do
      expect(DocumentNavigation.controllers).to eq([
          Documents::FirstController,
          Documents::SecondController,
          Documents::ThirdController,
      ])
    end
  end

  describe ".first" do
    it "delegates to .controllers" do
      expect(described_class.first).to eq(described_class.controllers.first)
    end
  end

  describe ".document_type" do
    it "returns the document type string corresponding to the given controller" do
      expect(described_class.document_type(Documents::SecondController)).to eq "Doc-2"
    end
  end

  describe "#next" do
    context "when current controller is second to last or before" do
      before do
        allow(Documents::SecondController).to receive(:show?) { false }
      end

      it "returns numeric index for next non-skipped controller in main flow" do
        navigation = described_class.new(Documents::FirstController.new)
        expect(navigation.next).to eq(Documents::ThirdController)
      end
    end

    context "when current controller is the last" do
      it "returns nil" do
        navigation = described_class.new(Documents::ThirdController.new)
        expect(navigation.next).to be_nil
      end
    end
  end

  describe "#first_for_intake" do
    let(:intake) { build :intake }
    before do
      allow(Documents::FirstController).to receive(:show?) { false }
    end

    it "returns the first relevant controller for the given input" do
      navigation = described_class.new(ExternalController.new)
      expect(navigation.first_for_intake(intake)).to eq Documents::SecondController
    end
  end

  describe "#select" do
    let(:intake) { build :intake }
    before do
      allow(Documents::SecondController).to receive(:show?) { false }
    end

    it "returns an array of all controllers that should be displayed for the current intake" do
      navigation = described_class.new(Documents::ThirdController.new)
      expect(navigation.select(intake)).to eq [Documents::FirstController, Documents::ThirdController]
    end
  end

  describe "#types_for_intake" do
    let(:intake) { build :intake }
    before do
      allow(Documents::SecondController).to receive(:show?) { false }
    end

    it "returns an array of all document types that should be displayed for the current intake" do
      navigation = described_class.new(Documents::ThirdController.new)
      expect(navigation.types_for_intake(intake)).to eq ["Doc-1", "Doc-3"]
    end
  end

  describe "#controller_for" do
    it "returns the controller for the doc type" do
      if(described_class.controller_type_mapping.keys.include?('Doc-1')) then
        # the DocumentNavigation hasn't been initialized elsewhere and cached
        # this branch will run if ONLY this spec file is run
        expect(described_class.controller_for('Doc-1')).to eq(Documents::FirstController)
      else
        # look at the actuals, since initialization is done.
        # this will run in the context of a larger test
        expect(described_class.controller_for('1099-MISC')).to eq(Documents::Form1099miscsController)
      end

    end

    it "returns nothing for an unregistered doc type" do
      expect(described_class.controller_for('some-nonsense')).to be_nil
    end
  end
end
