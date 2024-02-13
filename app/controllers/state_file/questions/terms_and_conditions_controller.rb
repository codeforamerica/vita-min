module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController


      # def update
      #   # binding.pry
      #   @li_items = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_html', privacy_policy_link: state_file_privacy_policy_path).split('</li>')
      #   render action: 'edit'
      # end

      def edit
        @li_items = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_html', privacy_policy_link: state_file_privacy_policy_path).split('</li>')
        unless Flipper.enabled?(:sms_notifications)
          @li_items.each_with_index do |li_item, idx|
            if li_item.include?('SMS')
              @li_items[idx] = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_no_sms_html')
            end
          end
        end
      end

      private
      def next_path
        binding.pry
        if current_intake.consented_to_terms_and_conditions_no?
          if params[:us_state] == 'az'
            return az_questions_declined_terms_and_conditions_path
          else
            return ny_questions_declined_terms_and_conditions_path
          end
        end

        super
      end
    end
  end
end