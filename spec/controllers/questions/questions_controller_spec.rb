require "rails_helper"

RSpec.describe Questions::QuestionsController do
  describe "#form_navigation" do
    context "without a current intake" do
      before do
        allow(subject).to receive(:current_intake).and_return(nil)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(QuestionNavigation)
      end
    end

    context "full service intake" do
      let(:intake) { create :intake }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(QuestionNavigation)
      end
    end

    context "eip only intake" do
      let(:eip_intake) { create :intake, :eip_only }

      before do
        allow(subject).to receive(:current_intake).and_return(eip_intake)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(EipOnlyNavigation)
      end
    end
  end

  describe ".to_path_helper" do
    context "with a random child controller" do
      let(:controller_class) { Documents::IdsController }

      it "returns the correct path helper" do
        expect(controller_class.to_path_helper(locale: :es)).to eq(ids_documents_path(locale: :es))
      end
    end
  end
end
