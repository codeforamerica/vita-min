module StateFile
  class NyCountyForm < QuestionsForm
    set_attributes_for :intake,
                       :residence_county,
                       :nyc_full_year_resident

    validates :residence_county, presence: true
    validate :set_nyc_full_year_resident

    def save
      if @intake.residence_county != self.residence_county
        @intake.school_district = nil
      end
      @intake.assign_attributes(attributes_for(:intake))
      @intake.save
    end

    def set_nyc_full_year_resident
      nyc_counties = ['New York (Manhattan)', 'Manhattan (see New York)', 'Kings (Brooklyn)', 'Richmond (Staten Island)', 'Queens', 'Bronx']
      if nyc_counties.include?(residence_county) && @intake.eligibility_lived_in_state_yes?
        self.nyc_full_year_resident = 'yes'
      else
        self.nyc_full_year_resident = 'no'
      end
    end
  end
end