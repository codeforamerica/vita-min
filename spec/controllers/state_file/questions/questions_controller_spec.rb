require "rails_helper"

class QuestionOneController < StateFile::Questions::QuestionsController; end

class QuestionTwoController < StateFile::Questions::QuestionsController; end

class QuestionThreeController < StateFile::Questions::QuestionsController
  def self.navigation_actions
    [:index, :new]
  end
end

class QuestionFourController < StateFile::Questions::QuestionsController; end

class QuestionNavigation < Navigation::StateFileBaseQuestionNavigation
  include ControllerNavigation
  FLOW = [QuestionOneController, QuestionTwoController, QuestionThreeController, QuestionFourController]
end

RSpec.describe StateFile::Questions::QuestionsController do
  describe "#prev_path" do
    let(:question_navigation) { QuestionNavigation.new(current_controller) }

    before do
      allow(current_controller).to receive(:current_intake).and_return(nil)
      allow(current_controller).to receive(:form_navigation).and_return(question_navigation)
    end

    context "when the controller has only one navigation action" do
      let(:current_controller) { QuestionTwoController.new }
      before do
        allow(current_controller).to receive(:action_name).and_return("edit")
        routes.draw { get "/question_one" => "question_one#edit" }
      end

      it "returns the previous controller's edit action" do
        expect(current_controller.send(:prev_path)).to eq(QuestionOneController.to_path_helper)
      end
    end

    context "when the controller has multiple navigation actions" do
      let(:current_controller) { QuestionThreeController.new }
      before do
        routes.draw { get "/question_three" => "question_three#index" }
      end

      context "the current action is in the navigation_actions list" do
        before do
          allow(current_controller).to receive(:action_name).and_return("new")
        end

        it "returns the current controller's previous action" do
          expect(current_controller.send(:prev_path)).to eq(QuestionThreeController.to_path_helper({action: :index}))
        end
      end

      context "the current action is not in the list due to validation errors causing the create action to render the new template" do
        before do
          allow(current_controller).to receive(:action_name).and_return("create")
        end

        it "returns the current controller's previous action" do
          expect(current_controller.send(:prev_path)).to eq(QuestionThreeController.to_path_helper({action: :index}))
        end
      end
    end

    context "when the previous controller has multiple navigation actions" do
      let(:current_controller) { QuestionFourController.new }
      before do
        allow(current_controller).to receive(:action_name).and_return("edit")
        routes.draw { get "/question_three" => "question_three#index" }
      end

      it "returns the previous controller's first action" do
        expect(current_controller.send(:prev_path)).to eq(QuestionThreeController.to_path_helper({action: :index}))
      end
    end
  end
end