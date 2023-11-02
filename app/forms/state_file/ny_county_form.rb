module StateFile
  class NyCountyForm < QuestionsForm
    set_attributes_for :intake,
                       :residence_county

    validates :residence_county, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end