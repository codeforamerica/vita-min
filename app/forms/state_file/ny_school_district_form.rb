require 'csv'

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

    def self.existing_attributes(intake)
      name = NySchoolDistricts.combined_name(intake)
      if name
        super.merge(school_district: name)
      else
        super
      end
    end
  end
end