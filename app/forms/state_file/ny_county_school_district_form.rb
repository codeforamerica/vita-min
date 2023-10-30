module StateFile
  class NyCountySchoolDistrictForm < QuestionsForm
    set_attributes_for :intake,
                       :residence_county, :school_district, :school_district_number

    validates :residence_county, presence: true
    validates :school_district, presence: true
    validates :school_district_number, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end