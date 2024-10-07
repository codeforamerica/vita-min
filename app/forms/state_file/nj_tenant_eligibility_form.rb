module StateFile
  class NjTenantEligibilityForm < QuestionsForm
    set_attributes_for :intake,
                       :tenant_home_subject_to_property_taxes,
                       :tenant_building_multi_unit,
                       :tenant_access_kitchen_bath,
                       :tenant_more_than_one_main_home_in_nj,
                       :tenant_shared_rent_not_spouse,
                       :tenant_same_home_spouse

    def save
      @intake.update(attributes_for(:intake))

      if StateFile::NjTenantEligibilityHelper.determine_eligibility(@intake) != StateFile::NjTenantEligibilityHelper::ADVANCE
        @intake.update({
                         rent_paid: nil
        })
      end
    end
  end
end