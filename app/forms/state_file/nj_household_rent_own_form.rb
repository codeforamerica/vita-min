module StateFile
  class NjHouseholdRentOwnForm < QuestionsForm
    set_attributes_for :intake,
                       :household_rent_own

    validates :household_rent_own, presence: true

    def save
      if @intake.household_rent_own != self.household_rent_own
        @intake.rent_paid = nil
        @intake.property_tax_paid = nil
      end
      @intake.update(attributes_for(:intake))
    end
  end
end