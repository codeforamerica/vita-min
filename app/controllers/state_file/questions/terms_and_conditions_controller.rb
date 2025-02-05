module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController
      def edit
        owner = I18n.t(
          "general.owner.#{current_state_code}",
          default: I18n.t("general.owner.default")
        )
        @li_items = I18n.t(
          'state_file.questions.terms_and_conditions.edit.list_items_html',
          owner: owner,
          privacy_policy_link: state_file_privacy_policy_path
        ).scan(/<li>.*?<\/li>/m) # elements of the resulting array include <li> and </li> tags
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
