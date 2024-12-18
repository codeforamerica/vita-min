module StateFile
  class NcQssInfoForm < QuestionsForm
    set_attributes_for :intake, :spouse_death_year

    def self.valid_spouse_death_years
      current_tax_year = MultiTenantService.statefile.current_tax_year
      [current_tax_year - 1, current_tax_year - 2]
    end
    delegate :valid_spouse_death_years, to: :class

    validates :spouse_death_year, inclusion: { in: valid_spouse_death_years.map(&:to_s), message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
