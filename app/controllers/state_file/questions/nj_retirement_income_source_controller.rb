module StateFile
  module Questions
    class NjRetirementIncomeSourceController < QuestionsController

      before_action :load_1099r

      def load_1099r
        @index = params[:index].present? ? params[:index].to_i : 0
        @state_file_1099r =
          if params[:index].present?
            current_intake.state_file1099_rs[params[:index].to_i]
          else
            current_intake.state_file1099_rs.first
          end

        @name_1099r = @state_file_1099r.payer_name
        @taxpayer_name = @state_file_1099r.recipient_name
        @amount = @state_file_1099r.taxable_amount
      end

      def initialized_edit_form
        attribute_keys = Attributes.new(form_class.attribute_names).to_sym
        state_specific_followup = retrieve_or_create_state_specific_followup
        form_class.new(state_specific_followup, form_class.existing_attributes(state_specific_followup).slice(*attribute_keys))
      end

      def initialized_update_form
        form_class.new(retrieve_or_create_state_specific_followup, form_params)
      end

      def retrieve_or_create_state_specific_followup
        unless @state_file_1099r.state_specific_followup.present?
          @state_file_1099r.state_specific_followup = StateFileNj1099RFollowup.create
          @state_file_1099r.save
        end

        @state_file_1099r.state_specific_followup
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
          NjRetirementIncomeSourceController.to_path_helper(options)
        end
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        next_index = @index + 1
        if next_index >= current_intake.direct_file_data.form1099r_nodes.length
          super
        else
          options[:index] = next_index
          NjRetirementIncomeSourceController.to_path_helper(options)
        end
      end
    end
  end
end

