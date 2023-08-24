require "rails_helper"

RSpec.describe Documents::DocumentUploadQuestionController do
  describe "#form_navigation" do
    context "without a current intake" do
      before do
        allow(subject).to receive(:current_intake).and_return(nil)
      end

      it "uses the DocumentNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(DocumentNavigation)
      end
    end

    context "full service intake" do
      let(:intake) { create :intake }

      before do
        sign_in intake.client
      end

      it "uses the DocumentNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(DocumentNavigation)
      end
    end
  end

  describe ".show?" do
    before do
      module TestingClass
        class ExampleDocumentUploadController < Documents::DocumentUploadQuestionController
          def self.document_type; end
        end
      end
    end

    context "for intakes without 211 source" do
      let(:intake) { create :intake }

      it "returns true" do
        expect(TestingClass::ExampleDocumentUploadController.show?(intake)).to eq(true)
      end
    end
  end
end