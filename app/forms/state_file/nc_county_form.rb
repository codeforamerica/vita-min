module StateFile
  class NcCountyForm < QuestionsForm
    set_attributes_for :intake, :residence_county, :moved_after_hurricane_helene, :county_during_hurricane_helene

    validates :residence_county, inclusion: { in: StateFileNcIntake::COUNTIES.keys, message: I18n.t("forms.errors.nc_county.county.presence") }
    with_options unless: -> { NcResidenceCountyConcern.designated_hurricane_county?(residence_county) } do
      validates :moved_after_hurricane_helene, presence: true
    end
    with_options if: -> { moved_after_hurricane_helene == "yes" } do
      validates :county_during_hurricane_helene, inclusion: { in: StateFileNcIntake::COUNTIES.keys, message: I18n.t("forms.errors.nc_county.county.presence") }
    end

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
