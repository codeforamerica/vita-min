module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController


      def update
        # binding.pry
        @li_items = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_html', privacy_policy_link: state_file_privacy_policy_path).split('</li>')
      end

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
        # binding.pry
        if current_intake.has_disqualifying_eligibility_answer?
          session[:offboarded_from] = self.class.to_path_helper(from_path_params)
          return offboarding_path
        end

        super
      end
    end
  end
end