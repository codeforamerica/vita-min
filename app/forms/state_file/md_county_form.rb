module StateFile
  class MdCountyForm < QuestionsForm
    set_attributes_for :intake, :residence_county, :political_subdivision

    validates :residence_county,
              presence: true,
              inclusion: { in: MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.keys }
    validates :political_subdivision,
              presence: true,
              inclusion: { in: :valid_subdivisions }

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def valid_subdivisions
      return MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.values.flat_map(&:keys) unless residence_county.present?
      MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS[residence_county]&.keys || []
    end
  end
end