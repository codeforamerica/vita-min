module StateFile
  class NjCountyForm < QuestionsForm
    set_attributes_for :intake,
                       :county

    validates :county, presence: true

    def save
      if @intake.county != self.county
        @intake.municipality_code = nil
        @intake.municipality_name = nil
      end
      @intake.assign_attributes(attributes_for(:intake))
      @intake.save
    end
  end
end