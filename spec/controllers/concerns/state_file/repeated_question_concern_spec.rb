require "rails_helper"

RSpec.describe StateFile::RepeatedQuestionConcern, type: :controller do
  controller(StateFile::Questions::QuestionsController) do
    include StateFile::RepeatedQuestionConcern

    def index
      head :ok
    end

    def num_items = 3

    def load_item(index)
      index
    end
  end

  # Which state we use doesn't matter, we just need a signed-in intake to use QuestionsController
  let(:intake) { create(:state_file_az_intake) }
  before do
    sign_in intake
    allow(controller.class).to receive(:to_path_helper) { |params| "/path?#{params.to_param}" }
    allow_any_instance_of(StateFile::Questions::QuestionsController).to receive(:next_path).and_return("/next_path")
    allow_any_instance_of(StateFile::Questions::QuestionsController).to receive(:prev_path).and_return("/prev_path")
  end

  describe "#next_path" do
    context "when return_to_review parameter is passed in" do
      context "and controller does not require all repeated items to be reviewed before returning" do
        it "returns to the review screen" do
          get :index, params: { return_to_review: "y", index: "1" }

          expect(subject.next_path).to eq("/next_path")
        end
      end

      context "and controller requires all repeated items should be reviewed before returning" do
        before do
          allow_any_instance_of(StateFile::RepeatedQuestionConcern).to receive(:review_all_items_before_returning_to_review).and_return(true)
        end
        it "goes to the next item with the return_to_review param" do
          get :index, params: { return_to_review: "y", index: "1" }

          expect(subject.next_path).to eq("/path?index=2&return_to_review=y")
        end
      end
    end

    context "when return_to_review parameter is not passed in" do
      context "when no index is passed in" do
        it "next path is index = 1" do
          get :index
          expect(subject.next_path).to eq("/path?index=1")
        end
      end

      context "when an index is passed in that is < num_items - 1" do
        it "next path has an incremented index" do
          get :index, params: { index: "1" }
          expect(subject.next_path).to eq("/path?index=2")
        end
      end

      context "when an index is passed in that == num_items - 1" do
        it "next path is the next controller" do
          get :index, params: { index: "2" }
          expect(subject.next_path).to eq("/next_path")
        end
      end
    end
  end

  describe "#prev_path" do
    context "when index is > 0" do
      it "prev path has a decremented index" do
        get :index, params: { index: "1" }
        expect(subject.prev_path).to eq("/path?index=0")
      end
    end

    context "when index is 0 or omitted" do
      it "prev path is whichever is previous overall" do
        get :index
        expect(subject.prev_path).to eq("/prev_path")
      end
    end
  end
end
