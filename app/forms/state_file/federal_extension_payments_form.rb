module StateFile
  class FederalExtensionPaymentsForm < QuestionsForm
    set_attributes_for :intake, :paid_federal_extension_payments
    validates :paid_federal_extension_payments, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
