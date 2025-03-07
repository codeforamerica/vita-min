module StateFile
  module Questions
    class TermsAndConditionsController < QuestionsController
      def edit
        owner = I18n.t(
          "general.owner.#{current_state_code}",
          default: I18n.t("general.owner.default")
        )
        
        @li_items = []

        (1..13).each do |i|
          @li_items << if i == 8 && !Flipper.enabled?(:sms_notifications)
            t('state_file.questions.terms_and_conditions.edit.list_item_no_sms_html')
          else
            t("state_file.questions.terms_and_conditions.edit.list_item_#{i}_html",
                           owner: owner,
                           privacy_policy_link: state_file_privacy_policy_path)
                       end
        end
      end
    end
  end
end
