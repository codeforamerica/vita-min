module StateFile
  # This concern can be used by any controller that needs to show a page repeatedly for each of a list of items
  # It assumes the existence of `current_index` and `num_items` attributes/methods on the controller that includes it
  # It handles return to review for you
  # It requires you to add a hidden `index` input to your edit template
  module RepeatedQuestionConcern
    extend ActiveSupport::Concern

    included do
      before_action :set_index_and_load_item
    end

    attr_reader :current_index

    def set_index_and_load_item
      @current_index = params[:index].present? ? params[:index].to_i : 0
      load_item(@current_index)
    end

    def prev_path
      options = {}
      options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
      prev_index = current_index - 1
      if prev_index.negative?
        super
      else
        options[:index] = prev_index
        self.class.to_path_helper(options)
      end
    end

    def next_path
      options = {}
      options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
      next_index = current_index + 1
      if next_index >= num_items
        super
      else
        options[:index] = next_index
        self.class.to_path_helper(options)
      end
    end
  end
end
