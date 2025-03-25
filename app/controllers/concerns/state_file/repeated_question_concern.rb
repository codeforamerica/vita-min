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
      prev_index = current_index - index_decrement
      if prev_index.negative?
        super
      else
        options = { index: prev_index }
        prev_question_controller_class.to_path_helper(options)
      end
    end

    def next_path
      return super if params[:return_to_review].present? && !review_all_items_before_returning_to_review

      next_index = current_index + index_increment

      if next_index >= num_items
        super
      else
        options = {index: next_index}
        if params[:return_to_review].present? && review_all_items_before_returning_to_review
          options[:return_to_review] = params[:return_to_review]
        end

        next_question_controller_class.to_path_helper(options)
      end
    end

    private

    def index_decrement
      1
    end

    def index_increment
      1
    end

    def prev_question_controller_class
      self.class
    end

    def next_question_controller_class
      self.class
    end

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

    def review_all_items_before_returning_to_review
      # define in the controller if needed review all items instead of just one
      false
    end
  end
end
