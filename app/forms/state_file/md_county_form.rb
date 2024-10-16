module StateFile
  class MdCountyForm < QuestionsForm
    set_attributes_for :intake, :residence_county, :political_subdivision

    validates :residence_county,
              inclusion: { in: MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.keys },
              allow_blank: true
    validates :political_subdivision,
              presence: true,
              inclusion: { in: :valid_subdivisions }

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def valid_subdivisions
      if residence_county.present?
        MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS[residence_county]&.values || []
      else
        all_subdivisions
      end
    end

    def all_subdivisions
      MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.values.flat_map(&:values)
    end
  end
end