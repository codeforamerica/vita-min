require 'csv'

module StateFile
  class NySchoolDistrictForm < QuestionsForm
    set_attributes_for :intake,
                       :school_district_id

    validates :school_district_id, presence: true

    def save
      district = NySchoolDistricts.find_by_id(school_district_id.to_i)
      @intake.update(attributes_for(:intake).merge(
        school_district: district.district_name,
        school_district_number: district.code
      ))
    end
  end
end