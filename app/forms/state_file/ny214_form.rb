module StateFile
  class Ny214Form < QuestionsForm
    set_attributes_for :intake,
                       :ny_mailing_street,
                       :ny_mailing_apartment,
                       :ny_mailing_city,
                       :ny_mailing_zip,
                       :occupied_residence,
                       :property_over_limit,
                       :public_housing,
                       :nursing_home,
                       :household_fed_agi,
                       :household_ny_additions,
                       :household_ssi,
                       :household_cash_assistance,
                       :household_other_income,
                       :household_rent_own,
                       :household_rent_amount,
                       :household_rent_adjustments,
                       :household_own_propety_tax,
                       :household_own_assessments

    def save
      self.household_rent_own ||= 'unfilled'
      self.nursing_home ||= 'unfilled'
      self.occupied_residence ||= 'unfilled'
      self.property_over_limit ||= 'unfilled'
      self.public_housing ||= 'unfilled'
      @intake.update(attributes_for(:intake))
    end
  end
end