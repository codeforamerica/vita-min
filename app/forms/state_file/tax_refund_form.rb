module StateFile
  class TaxRefundForm < QuestionsForm
    include DateHelper
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :bank_name
    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation

    validates :payment_or_deposit_type, presence: true

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validates :bank_name, presence: true
      validates :account_type, presence: true

      validates :account_number, presence: true, confirmation: true, numericality: true
      validates :account_number_confirmation, presence: true

      validates :routing_number, presence: true, confirmation: true, length: { is: 9 }, numericality: true
      validates :routing_number_confirmation, presence: true

      with_options if: -> { account_number.present? && routing_number.present? } do
        validate :bank_numbers_not_equal
      end
    end

    def save
      @intake.update!(attributes_for(:intake))
    end

    def self.existing_attributes(intake)
      attributes = super
      attributes.except(:routing_number, :account_number, :routing_number_confirmation, :account_number_confirmation)
    end

    private

    def bank_numbers_not_equal
      if routing_number == account_number
        errors.add(:account_number, I18n.t("forms.errors.routing_account_number.not_same"))
        errors.add(:routing_number, I18n.t("forms.errors.routing_account_number.not_same"))
      end
    end
  end
end
