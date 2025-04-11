module StateFile
  module Questions
    class NjTenantEligibilityController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { set_checkboxes }

      def set_checkboxes
        @checkbox_collection = [
          {
            method: :tenant_home_subject_to_property_taxes,
            label: I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_home_subject_to_property_taxes")
          },
          { 
            method: :tenant_building_multi_unit,
            label: I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_building_multi_unit"),
            opens_follow_up_with_id: "tenant_access_kitchen_bath_followup", 
          },
          { 
            method: :tenant_access_kitchen_bath,
            label: I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_access_kitchen_bath"),
            follow_up_id: "tenant_access_kitchen_bath_followup"
          },
        ]
        if current_intake.filing_status_mfs?
          @checkbox_collection << {
            method: :tenant_same_home_spouse,
            label: I18n.t("state_file.questions.nj_tenant_eligibility.edit.tenant_same_home_spouse")
          }
        end
        @checkbox_collection << {
          method: :tenant_none_of_the_above,
          label: I18n.t("general.none_of_these")
        }
      end

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjHouseholdRentOwnController.to_path_helper(options)
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        
        if StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjTenantEligibilityHelper::INELIGIBLE
          options[:on_home_or_rental] = :rental
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        else
          NjTenantRentPaidController.to_path_helper(options)
        end
      end
    end
  end
end