module StateFile
  class NjVeteransExemptionForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_veteran,
                       :spouse_veteran

    validates :primary_veteran, presence: true
    validates :spouse_veteran, presence: true, if: -> { intake.filing_status_mfj? }
    def save
      @intake.update(attributes_for(:intake))
    end
  end
end