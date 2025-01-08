module StateFile
  module Questions
    class NjHomeownerEligibilityController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { set_checkboxes }

      def set_checkboxes
        @checkbox_collection = [
          {
            method: :homeowner_home_subject_to_property_taxes,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_home_subject_to_property_taxes")
          },
          { 
            method: :homeowner_more_than_one_main_home_in_nj,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_more_than_one_main_home_in_nj"),
          },
          { 
            method: :homeowner_shared_ownership_not_spouse,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_shared_ownership_not_spouse"),
          },
          {
            method: :homeowner_main_home_multi_unit,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_main_home_multi_unit"),
            has_follow_up_id: 'homeowner_multi_unit_followup'
          },
          {
            method: :homeowner_main_home_multi_unit_max_four_one_commercial,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_main_home_multi_unit_max_four_one_commercial"),
            is_follow_up_id: 'homeowner_multi_unit_followup'
          },
        ]
        if current_intake.filing_status_mfs?
          @checkbox_collection << {
            method: :homeowner_same_home_spouse,
            label: I18n.t("state_file.questions.nj_homeowner_eligibility.edit.homeowner_same_home_spouse")
          }
        end
        @checkbox_collection << {
          method: :homeowner_none_of_the_above,
          label: I18n.t("general.none_of_these")
        }
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
          options[:on_home_or_rental] = :home
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        elsif StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::WORKSHEET
          NjHomeownerPropertyTaxWorksheetController.to_path_helper(options)
        else
          NjHomeownerPropertyTaxController.to_path_helper(options)
        end
      end

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjHouseholdRentOwnController.to_path_helper(options)
      end
    end
  end
end