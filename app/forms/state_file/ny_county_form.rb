module StateFile
  class NyCountyForm < QuestionsForm
    set_attributes_for :intake,
                       :residence_county,
                       :nyc_full_year_resident

    validates :residence_county, presence: true
    validate :set_nyc_full_year_resident

    def save
      @intake.update(attributes_for(:intake))
    end

    def set_nyc_full_year_resident
      nyc_counties = ['New York (Manhattan)', 'Manhattan (see New York)', 'Kings (Brooklyn)', 'Richmond (Staten Island)', 'Queens', 'Bronx']
      if nyc_counties.include?(residence_county)
        self.nyc_full_year_resident = 'yes'
      else
        self.nyc_full_year_resident = 'no'
      end
    end
  end
end