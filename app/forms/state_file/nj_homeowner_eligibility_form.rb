module StateFile
  class NjHomeownerEligibilityForm < QuestionsForm
    set_attributes_for :intake,
                       :homeowner_home_subject_to_property_taxes,
                       :homeowner_main_home_multi_unit,
                       :homeowner_main_home_multi_unit_max_four_one_commercial,
                       :homeowner_more_than_one_main_home_in_nj,
                       :homeowner_shared_ownership_not_spouse,
                       :homeowner_same_home_spouse

    def save
      @intake.update(attributes_for(:intake))

      if StateFile::NjHomeownerEligibilityHelper.determine_eligibility(@intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
        @intake.update({
          property_tax_paid: nil
        })
      end
    end
  end
end
