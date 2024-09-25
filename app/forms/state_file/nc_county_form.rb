module StateFile
  class NcCountyForm < QuestionsForm
    set_attributes_for :intake,
      :residence_county

    validates :residence_county,
      presence: true,
      inclusion: { in: StateFileNcIntake::COUNTIES.keys }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
