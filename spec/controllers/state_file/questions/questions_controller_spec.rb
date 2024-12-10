require "rails_helper"

class QuestionOneController < StateFile::Questions::QuestionsController; end

class QuestionTwoController < StateFile::Questions::QuestionsController; end

class QuestionThreeController < StateFile::Questions::QuestionsController
  def self.navigation_actions
    [:index, :new, :edit]
  end
end

class QuestionFourController < StateFile::Questions::QuestionsController; end

class QuestionNavigation < Navigation::StateFileBaseQuestionNavigation
  include ControllerNavigation
  FLOW = [QuestionOneController, QuestionTwoController, QuestionThreeController, QuestionFourController]
end

RSpec.describe StateFile::Questions::QuestionsController do
  describe "#prev_path" do

    before do
      allow(current_controller).to receive(:current_intake).and_return(nil)
      allow(current_controller).to receive(:form_navigation).and_return(QuestionNavigation.new(current_controller))
    end

    context "when the controller has only one navigation action" do
      let(:current_controller) { QuestionTwoController.new }

      context "when the current action is the single navigation action" do
        before do
          allow(current_controller).to receive(:action_name).and_return("edit")
        end

        it "returns the previous controller's edit action" do
          expect(QuestionOneController).to receive(:to_path_helper)
          current_controller.send(:prev_path)
        end
      end

      context "when the current action is not in the list" do
        before do
          allow(current_controller).to receive(:action_name).and_return("create")
        end

        it "returns the previous controller's edit action" do
          expect(QuestionOneController).to receive(:to_path_helper)
          current_controller.send(:prev_path)
        end
      end
    end

    context "when the controller has multiple navigation actions" do
      let(:current_controller) { QuestionThreeController.new }

      context "the current action is in the navigation_actions list" do
        context "is the first item" do
          before do
            allow(current_controller).to receive(:action_name).and_return("index")
          end

          it "returns the previous controller's first action" do
            expect(QuestionTwoController).to receive(:to_path_helper)
            current_controller.send(:prev_path)
          end
        end

        context "is not the first item" do
          before do
            allow(current_controller).to receive(:action_name).and_return("edit")
          end

          it "returns the current controller's previous action" do
            expect(QuestionThreeController).to receive(:to_path_helper).with({action: :index})
            current_controller.send(:prev_path)
          end
        end
      end

      context "the current action is not in the navigation_actions list" do

        context "due to validation errors causing the create action to render the new template" do
          before do
            allow(current_controller).to receive(:action_name).and_return("create")
          end

          it "returns the current controller's previous action" do
            expect(QuestionThreeController).to receive(:to_path_helper).with({action: :index})
            current_controller.send(:prev_path)
          end
        end

        context "due to being an unlisted action" do
          before do
            allow(current_controller).to receive(:action_name).and_return("edit")
          end

          it "returns the current controller's first action" do
            expect(QuestionThreeController).to receive(:to_path_helper).with({action: :index})
            current_controller.send(:prev_path)
          end
        end
      end
    end

    context "when the previous controller has multiple navigation actions" do
      let(:current_controller) { QuestionFourController.new }
      before do
        allow(current_controller).to receive(:action_name).and_return("edit")
      end

      it "returns the previous controller's first action" do
        expect(QuestionThreeController).to receive(:to_path_helper).with({action: :index})
        current_controller.send(:prev_path)
      end
    end
  end
end