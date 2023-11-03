module StateFile
  class NyPtcOccupiedResidenceForm < QuestionsForm
    set_attributes_for :intake,
                       :occupied_residence

    validates :occupied_residence, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end