module StateFile
  class TaxesOwedForm < QuestionsForm
    include DateHelper
    set_attributes_for :intake,
      :payment_or_deposit_type, :routing_number, :account_number, :account_type,
      :bank_name, :withdraw_amount

    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation
    set_attributes_for :date, :date_electronic_withdrawal_month, :date_electronic_withdrawal_year, :date_electronic_withdrawal_day

    validates :payment_or_deposit_type, presence: true
    validate :date_electronic_withdrawal_is_valid_date, unless: -> { payment_or_deposit_type == "mail" }
    validates :bank_name, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validates :withdraw_amount, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validates :account_type, presence: true, unless: -> { payment_or_deposit_type == "mail" }

    with_options if: -> { (account_number.present? && account_number != @intake.account_number) || account_number_confirmation.present? } do
      validates :account_number, confirmation: true, unless: -> { payment_or_deposit_type == "mail" }
      validates :account_number_confirmation, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    end

    with_options if: -> { (routing_number.present? && routing_number != @intake.routing_number) || routing_number_confirmation.present? } do
      validates :routing_number, confirmation: true, unless: -> { payment_or_deposit_type == "mail" }
      validates :routing_number_confirmation, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    end

    def save
      attrs = attributes_for(:intake)
      @intake.update!(attrs.merge(date_electronic_withdrawal: date_electronic_withdrawal))
    end

    def self.existing_attributes(intake)
      attributes = super
      attributes.merge!(
        date_electronic_withdrawal_day: intake.date_electronic_withdrawal&.day,
        date_electronic_withdrawal_month: intake.date_electronic_withdrawal&.month,
        date_electronic_withdrawal_year: intake.date_electronic_withdrawal&.year,
      )
      attributes.except(:routing_number, :account_number, :routing_number_confirmation, :account_number_confirmation)
    end

    private

    def date_electronic_withdrawal
      parse_date_params(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day)
    end

    def date_electronic_withdrawal_is_valid_date
      valid_text_date(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day, :date_electronic_withdrawal)
    end
  end
end
