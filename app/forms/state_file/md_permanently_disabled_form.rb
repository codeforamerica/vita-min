module StateFile
  class MdPermanentlyDisabledForm < QuestionsForm
    set_attributes_for :intake, :primary_disabled, :spouse_disabled, :primary_proof_of_disability_submitted, :spouse_proof_of_disability_submitted

    attr_accessor :mfj_disability
    validates_presence_of :mfj_disability, if: -> { intake.filing_status_mfj?}
    validates :primary_disabled, inclusion: { in: %w[yes no], message: :blank }, unless: -> { intake.filing_status_mfj? }
    # no skipping the validation if they're a senior
    validates :primary_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :primary_disability_selected?
    validates :spouse_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: :spouse_disability_selected?
    validates :primary_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: -> { primary_disabled == "yes" }
    validates :spouse_proof_of_disability_submitted, inclusion: { in: %w[yes no], message: :blank }, if: -> { spouse_disabled == "yes" }


    def save
      if intake.filing_status_mfj?
        case mfj_disability
        when "me"
          @intake.update(primary_disabled: "yes", spouse_disabled: "no",  primary_proof_of_disability_submitted: primary_proof_of_disability_submitted)
        when "spouse"
          @intake.update(primary_disabled: "no", spouse_disabled: "yes", spouse_proof_of_disability_submitted: spouse_proof_of_disability_submitted)
        when "both"
          @intake.update(primary_disabled: "yes", spouse_disabled: "yes", primary_proof_of_disability_submitted: primary_proof_of_disability_submitted, spouse_proof_of_disability_submitted: spouse_proof_of_disability_submitted)
        when "none"
          @intake.update(primary_disabled: "no", spouse_disabled: "no", primary_proof_of_disability_submitted: nil, spouse_proof_of_disability_submitted: nil)
        end
      elsif primary_disabled == "no"
        @intake.update(
            primary_disabled: "no",
            primary_proof_of_disability_submitted: nil
          )
      else
        @intake.update(attributes_for(:intake))
      end
    end

    private

    def primary_disability_selected?
      (mfj_disability.in?(%w[me both]) || primary_disabled == "yes") && !(intake.primary_senior? || intake.spouse_senior?)
    end

    def spouse_disability_selected?
      mfj_disability.in?(%w[spouse both]) && !(intake.primary_senior? || intake.spouse_senior?)
    end
  end
end
