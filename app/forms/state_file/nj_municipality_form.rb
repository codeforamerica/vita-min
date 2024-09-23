require 'csv'

module StateFile
  class NjMunicipalityForm < QuestionsForm
    set_attributes_for :intake,
                       :municipality_code

    validates :municipality_code, presence: true

    def save
      municipality_name = Efile::Nj::NjMunicipalities.find_name_by_county_and_code(@intake.county, municipality_code)
      @intake.update(attributes_for(:intake).merge(
        municipality_name: municipality_name,
        municipality_code: municipality_code
      ))
    end
  end
end