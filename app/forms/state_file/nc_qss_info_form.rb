module StateFile
  class NcQssInfoForm < QuestionsForm
    set_attributes_for :intake, :spouse_death_year

    validates :spouse_death_year, presence: true, inclusion: { in: [2022, 2023] }
    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
