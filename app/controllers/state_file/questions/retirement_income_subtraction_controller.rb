module StateFile
  module Questions
    class RetirementIncomeSubtractionController < QuestionsController
      include RepeatedQuestionConcern

      attr_reader :state_file_1099r

      def initialized_edit_form
        attribute_keys = Attributes.new(form_class.attribute_names).to_sym
        state_specific_followup = find_or_create_state_specific_followup
        form_class.new(state_specific_followup, form_class.existing_attributes(state_specific_followup).slice(*attribute_keys))
      end

      def initialized_update_form
        form_class.new(find_or_create_state_specific_followup, form_params)
      end

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.eligible_1099rs.present?
      end

      private

      def num_items
        current_intake.eligible_1099rs.count
      end

      def load_item(index)
        @state_file_1099r = current_intake.eligible_1099rs[index]
        if @state_file_1099r.nil?
          render "public_pages/page_not_found", status: 404
        end
      end

      def find_or_create_state_specific_followup
        unless @state_file_1099r.state_specific_followup.present?
          @state_file_1099r.update(state_specific_followup: followup_class.create)
        end
        @state_file_1099r.state_specific_followup
      end

      def followup_class
        raise NotImplementedError, "Implement Subclass#followup_class to return the state-specific 1099R followup model class"
      end
    end
  end
end
