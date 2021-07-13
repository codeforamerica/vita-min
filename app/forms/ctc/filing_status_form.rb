module Ctc
  class FilingStatusForm < QuestionsForm
    set_attributes_for :tax_return, :filing_status

    validates :filing_status, presence: true

    def save
      @intake.update(tax_return_attributes: attributes_for(:tax_return))
    end

    def self.existing_attributes(intake)
      return super unless intake.client.tax_returns.present?

      # bank_name is encrypted, but we want it to be editable for clients
      tax_return_attributes = { filing_status: intake.client.tax_returns.last.filing_status }
      HashWithIndifferentAccess.new(intake.attributes.merge(intake.attributes.merge(tax_return_attributes)))
    end
  end
end