require "rails_helper"

RSpec.describe Questions::QuestionsController do
  describe "#form_navigation" do
    context "without a current intake" do
      before do
        allow(subject).to receive(:current_intake).and_return(nil)
      end

      it "uses the GyrQuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(GyrQuestionNavigation)
      end
    end

    context "full service intake" do
      let(:intake) { create :intake }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "uses the GyrQuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(GyrQuestionNavigation)
      end
    end
  end

  describe ".to_path_helper" do
    context "with a random child controller" do
      let(:controller_class) { Documents::IdsController }

      it "returns the correct path helper" do
        expect(controller_class.to_path_helper).to eq(ids_documents_path)
      end

      context "with a specific locale" do
        before do
          allow(I18n).to receive(:locale).and_return(:es)
        end

        it "computes the route appropriate to that locale" do
          expect(controller_class.to_path_helper).to eq(ids_documents_path(locale: :es))
        end
      end
    end
  end

  describe "#prev_path" do
    before do
      allow_any_instance_of(GyrQuestionNavigation).to receive(:current_controller).and_return Questions::AdoptedChildController.new
      allow_any_instance_of(Questions::AdoptedChildController).to receive(:current_intake).and_return nil
      stub_const("GyrQuestionNavigation::FLOW",
                 [
                     Questions::WelcomeController,
                     Questions::AdoptedChildController,
                     Questions::FinalInfoController,
                 ]
      )
    end

    it "returns the path to the previous controller in the flow" do
      expect(subject.prev_path).to eq Questions::WelcomeController.to_path_helper
    end
  end

  describe "#next_path" do
    let!(:current_intake) { double(Intake) }

    before do
      allow_any_instance_of(GyrQuestionNavigation).to receive(:current_controller).and_return Questions::AdoptedChildController.new
      allow_any_instance_of(Questions::AdoptedChildController).to receive(:current_intake).and_return current_intake
      stub_const("GyrQuestionNavigation::FLOW",
                 [
                     Questions::WelcomeController,
                     Questions::AdoptedChildController,
                     Questions::FinalInfoController,
                 ]
      )
    end

    it "returns the path to the previous controller in the flow" do
      expect(subject.next_path).to eq Questions::FinalInfoController.to_path_helper
    end
  end
end
