module Ctc
  class ConfirmInformationForm < QuestionsForm
    set_attributes_for :intake, :primary_signature_pin, :spouse_signature_pin

    validates :primary_signature_pin, presence: true, signature_pin: true
    validates :spouse_signature_pin, presence: true, signature_pin: true, if: -> { @intake.filing_jointly? }

    def save
      @intake.update(attributes_for(:intake))
      @intake.touch(:primary_signature_pin_at)
      @intake.touch(:spouse_signature_pin_at) if @intake.filing_jointly?
    end
  end
end
