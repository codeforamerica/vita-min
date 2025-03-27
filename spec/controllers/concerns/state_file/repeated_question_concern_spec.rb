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
end
