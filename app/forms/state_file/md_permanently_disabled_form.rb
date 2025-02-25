module StateFile
  class MdPermanentlyDisabledForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled, :primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj? }
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }
    validates :primary_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :primary_requires_proof?
    validates :spouse_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :spouse_requires_proof?

    def save
      attributes_to_save = attributes_for(:intake)
      if mfj_disability.present?
        attributes_to_save = case mfj_disability
                             when "primary"
                               attributes_to_save.merge(primary_disabled: "yes", spouse_disabled: "no")
                             when "spouse"
                               attributes_to_save.merge(primary_disabled: "no", spouse_disabled: "yes")
                             when "both"
                               attributes_to_save.merge(primary_disabled: "yes", spouse_disabled: "yes")
                             when "none"
                               attributes_to_save.merge(primary_disabled: "no", spouse_disabled: "no")
                             end
      end

      @intake.update(attributes_to_save)
    end

    private

    def primary_requires_proof?
      (mfj_disability.in?(%w[primary both]) || primary_disabled == "yes") && !intake.primary_senior?
    end

    def spouse_requires_proof?
      mfj_disability.in?(%w[spouse both]) && !intake.spouse_senior?
    end
  end
end
