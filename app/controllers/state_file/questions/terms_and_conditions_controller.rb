module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController

      def edit
        @li_items = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_html').split('</li>')
        unless Flipper.enabled?(:sms_notifications)
          @li_items.each_with_index do |li_item, idx|
            if li_item.include?('SMS')
              @li_items[idx] = I18n.t('state_file.questions.terms_and_conditions.edit.list_items_no_sms_html')
            end
          end
        end
      end
    end
  end
end