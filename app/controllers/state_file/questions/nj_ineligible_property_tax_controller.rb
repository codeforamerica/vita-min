module StateFile
  module Questions
    class NjIneligiblePropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      helper_method :ineligible_reason
      helper_method :on_home_or_rental

      def determine_reason
        if current_intake.household_rent_own_neither?
          return "neither"
        end

        if params[:on_home_or_rental] == "home"
          if current_intake.homeowner_home_subject_to_property_taxes_no?
            return "property_taxes"
          elsif current_intake.homeowner_main_home_multi_unit_yes? && current_intake.homeowner_main_home_multi_unit_max_four_one_commercial_no?
            return "multi_unit_conditions"
          end
        end

        if params[:on_home_or_rental] == "rental"
          if current_intake.tenant_home_subject_to_property_taxes_no?
            return "property_taxes"
          elsif current_intake.tenant_building_multi_unit_yes? && current_intake.tenant_access_kitchen_bath_no?
            return "multi_unit_conditions"
          end
        end
      end

      def ineligible_reason
        key = "reason_#{determine_reason}" if determine_reason.present?
        if key.present?
          I18n.t(
            "state_file.questions.nj_ineligible_property_tax.edit.#{key}",
            filing_year: current_tax_year
          )
        end
      end

      def on_home_or_rental
        key = "on_#{params[:on_home_or_rental]}" if params[:on_home_or_rental].present?
        if key.present?
          I18n.t(
            "state_file.questions.nj_ineligible_property_tax.edit.#{key}",
            filing_year: current_tax_year
          )
        end
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if current_intake.household_rent_own_both? && params[:on_home_or_rental] != "rental"
          NjTenantEligibilityController.to_path_helper(options)
        else
          StateFile::NjPropertyTaxFlowHelper.next_controller(options)
        end
      end
    end
  end
end

