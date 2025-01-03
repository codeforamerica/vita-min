module StateFile
  class MdHadHealthInsuranceForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    set_attributes_for :intake, :had_hh_member_without_health_insurance, :primary_did_not_have_health_insurance, :spouse_did_not_have_health_insurance, :authorize_sharing_of_health_insurance_info

    validates :had_hh_member_without_health_insurance, presence: true
    validate :one_member_did_not_have_health_insurance, if: -> { had_hh_member_without_health_insurance == "yes"}

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
      base_attrs = attributes_for(:intake)
      base_attrs.merge({ dependents_attributes: dependents_attributes.to_h })
      @intake.update!(base_attrs)
    end

    private

    def one_member_did_not_have_health_insurance
      unless @intake.has_dependent_without_health_insurance? || spouse_did_not_have_health_insurance == "yes" || primary_did_not_have_health_insurance == "yes"
        errors.add(:household_health_insurance, I18n.t("forms.errors.healthcare.one_box"))
      end
    end
  end
end
