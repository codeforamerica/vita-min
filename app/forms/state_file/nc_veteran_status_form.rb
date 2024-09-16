module StateFile
  class NcVeteranStatusForm < QuestionsForm
    set_attributes_for :intake, :primary_veteran, :spouse_veteran

    validates :primary_veteran, inclusion: { in: %w[yes no], message: :blank }
    validates :spouse_veteran, inclusion: { in: %w[yes no], message: :blank }, if: -> { intake.filing_status_mfj? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end