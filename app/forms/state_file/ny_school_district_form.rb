module StateFile
  class NySchoolDistrictForm < QuestionsForm
    set_attributes_for :intake,
                       :school_district,
                       :school_district_number

    validates :school_district, presence: true
    validates :school_district_number, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end