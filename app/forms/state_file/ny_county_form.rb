module StateFile
  class NyCountyForm < QuestionsForm
    set_attributes_for :intake,
                       :residence_county

    validates :residence_county, presence: true

    def save
      if @intake.residence_county != self.residence_county
        @intake.school_district = nil
      end
      @intake.assign_attributes(attributes_for(:intake))
      @intake.save
    end
  end
end