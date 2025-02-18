module StateFile
  # This concern can be used by any StateFile::Questions::QuestionsController that needs to show a page repeatedly for each of a list of items
  # It requires you to add a hidden `index` input to your edit template
  module RepeatedQuestionConcern
    include ReturnToReviewConcern
    extend ActiveSupport::Concern

    included do
      before_action :set_index_and_load_item
    end

    attr_reader :current_index

    def prev_path
      prev_index = current_index - 1
      if prev_index.negative?
        super
      else
        options = { index: prev_index }
        self.class.to_path_helper(options)
      end
    end

    def next_path
      return super if params[:return_to_review].present?
      
      next_index = current_index + 1
      if next_index >= num_items
        super
      else
        options = {index: next_index}
        self.class.to_path_helper(options)
      end
    end

    private

    def set_index_and_load_item
      @current_index = params[:index].present? ? params[:index].to_i : 0
      load_item(@current_index)
    end

    def num_items
      # define in controller
      raise NotImplementedError
    end

    def load_item(index)
      # define in controller
      raise NotImplementedError
    end

  end
end
