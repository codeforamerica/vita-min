module StateFile
  class NjDisabledExemptionForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_disabled,
                       :spouse_disabled
    
    validates :primary_disabled, presence: true, if: -> { !intake.direct_file_data.is_primary_blind? }
    validates :spouse_disabled, presence: true, if: -> { intake.filing_status_mfj? && !intake.direct_file_data.is_spouse_blind? }
    def save
      @intake.update(attributes_for(:intake))
    end

  end
end