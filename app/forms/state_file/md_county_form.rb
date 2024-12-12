module StateFile
  class MdCountyForm < QuestionsForm
    set_attributes_for :intake, :residence_county, :political_subdivision, :subdivision_code

    validates :residence_county,
              inclusion: {
                in: MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.keys,
                message: I18n.t("forms.errors.md_county.residence_county.presence")
              }
    validates :subdivision_code,
              inclusion: {
                in: :valid_subdivisions,
                message: I18n.t("forms.errors.md_county.subdivision_code.presence")
              }

    def save
      @intake.update(attributes_for(:intake))
      @intake.update(political_subdivision: subdivision_name)
    end

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

    def subdivision_name
      return nil if residence_county.blank? || subdivision_code.blank?
      MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS[residence_county].key(subdivision_code)
    end
  end
end
