module StateFile
  class NjHouseholdRentOwnForm < QuestionsForm
    set_attributes_for :intake,
                       :household_rent_own

    validates :household_rent_own, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end