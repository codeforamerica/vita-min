module StateFile
  class NjCountyMunicipalityForm < QuestionsForm
    set_attributes_for :intake,
                       :county,
                       :municipality_code

    validates :county, presence: true
    validates :municipality_code, presence: true

    def save
      municipality_name = Efile::Nj::NjMunicipalities.find_name_by_county_and_code(county, municipality_code)
      @intake.update(attributes_for(:intake).merge(
        municipality_name: municipality_name,
        municipality_code: municipality_code,
        county: county
      ))
    end
  end
end