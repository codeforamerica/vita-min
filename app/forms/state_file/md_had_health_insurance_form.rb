module StateFile
  class MdHadHealthInsuranceForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    set_attributes_for :intake, :had_hh_member_without_health_insurance, :primary_did_not_have_health_insurance, :spouse_did_not_have_health_insurance, :authorize_sharing_of_health_insurance_info
    # set_attributes_for :dependents, :did_not_have_health_insurance

    validates :had_hh_member_without_health_insurance, presence: true
    validate :one_member_had_health_insurance, if: -> { had_hh_member_without_health_insurance == "yes"}

    validates :authorize_sharing_of_health_insurance_info,
              presence: true,
              if: -> { had_hh_member_without_health_insurance == "yes" }


    def initialize(intake = nil, params = nil)
      super
      if params.present?
        @intake.assign_attributes(dependents_attributes: dependents_attributes.to_h)
      end
    end

    def save
      @intake.update!(attributes_to_save)
    end

    def attributes_to_save
      base_attrs = attributes_for(:intake)
      base_attrs.merge({ dependents_attributes: dependents_attributes.to_h })
    end

    def valid?
      dependents_valid = dependents.map { |d| d.valid?(:md_healthcare_screen_form) }
      super && dependents_valid.all?
    end

    private

    def one_member_had_health_insurance
      unless @intake.has_dependent_without_health_insurance? || spouse_did_not_have_health_insurance == "yes" || primary_did_not_have_health_insurance == "yes"
        errors.add(:household_health_insurance, I18n.t("forms.errors.healthcare.one_box"))
      end
    end
  end
end
