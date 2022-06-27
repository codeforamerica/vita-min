module Ctc
  class FilingStatusForm < QuestionsForm
    set_attributes_for :tax_return, :filing_status

    validates :filing_status, presence: true

    def save
      @intake.client.tax_returns.last.update(attributes_for(:tax_return))
    end
  end
end