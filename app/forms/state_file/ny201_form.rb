module StateFile
  class Ny201Form < QuestionsForm

    set_attributes_for :intake,
                       :primary_email,
                       :residence_county,
                       :school_district,
                       :school_district_number,
                       :nyc_full_year_resident,
                       :ny_other_additions

    def save
      @intake.update!(attributes_for(:intake))
    end

  end
end