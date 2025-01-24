module StateFile
  module Questions
    class MdRetirementIncomeSubtractionController < QuestionsController
      include ReturnToReviewConcern

      before_action :load_1099r

      attr_reader :index, :state_file_1099r

      def initialized_edit_form
        attribute_keys = Attributes.new(form_class.attribute_names).to_sym
        state_specific_followup = retrieve_or_create_state_specific_followup
        form_class.new(state_specific_followup, form_class.existing_attributes(state_specific_followup).slice(*attribute_keys))
      end

      def initialized_update_form
        form_class.new(retrieve_or_create_state_specific_followup, form_params)
      end

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.state_file1099_rs.length.positive?
      end

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        prev_index = @index - 1
        if prev_index.negative?
          super
        else
          options[:index] = prev_index
          MdRetirementIncomeSubtractionController.to_path_helper(options)
        end
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        next_index = @index + 1
        if next_index >= current_intake.state_file1099_rs.length
          super
        else
          options[:index] = next_index
          MdRetirementIncomeSubtractionController.to_path_helper(options)
        end
      end

      private

      def load_1099r
        @index = params[:index].present? ? params[:index].to_i : 0
        @state_file_1099r = current_intake.state_file1099_rs[@index]
        if @state_file_1099r.nil?
          render "public_pages/page_not_found", status: 404
        end
      end

      def retrieve_or_create_state_specific_followup
        unless @state_file_1099r.state_specific_followup.present?
          @state_file_1099r.update(state_specific_followup: StateFileMd1099RFollowup.create)
        end
        @state_file_1099r.state_specific_followup
      end

    end
  end
end
