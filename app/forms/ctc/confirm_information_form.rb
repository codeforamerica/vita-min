module Ctc
  class ConfirmInformationForm < QuestionsForm
    set_attributes_for :intake, :primary_ip_pin, :spouse_ip_pin

    validates :primary_ip_pin, presence: true, length: { is: 5 }, exclusion: { in: %w(00000), message: "00000 is not a valid PIN." }
    validates :spouse_ip_pin, presence: true, length: { is: 5 },  exclusion: { in: %w(00000), message: "00000 is not a valid PIN." },
              if: -> { @intake.tax_returns.last.filing_status_married_filing_jointly? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
