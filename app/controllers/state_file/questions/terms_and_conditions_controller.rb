module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController
      def edit
        ownership = current_state_code == "nj" ?
          "#{I18n.t('general.code_for_america')} #{I18n.t('general.and')} #{I18n.t('general.nj_ooi')}" :
          I18n.t('general.code_for_america')
          @li_items = I18n.t(
            'state_file.questions.terms_and_conditions.edit.list_items_html',
            ownership: ownership,
            privacy_policy_link: state_file_privacy_policy_path
          ).scan(/<li>.*?<\/li>/m) # elements of resulting array include <li> and </li> tags
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
