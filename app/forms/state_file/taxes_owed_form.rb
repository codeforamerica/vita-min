module StateFile
  class TaxesOwedForm < TaxRefundForm
    include DateHelper
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :bank_name,
                       :withdraw_amount

    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation
    set_attributes_for :date, :date_electronic_withdrawal_month, :date_electronic_withdrawal_year, :date_electronic_withdrawal_day

    validate :date_electronic_withdrawal_is_valid_date, unless: -> { payment_or_deposit_type == "mail" }
    validates :withdraw_amount, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validate :withdraw_amount_too_high?, unless: -> { payment_or_deposit_type == "mail" }

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
      attributes
    end

    private

    def date_electronic_withdrawal
      parse_date_params(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day)
    end

    def date_electronic_withdrawal_is_valid_date
      valid_text_date(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day, :date_electronic_withdrawal)
    end

    def withdraw_amount_too_high?
      owed_amount = intake.calculated_refund_or_owed_amount.abs
      if self.withdraw_amount.to_i > owed_amount
        self.errors.add(:withdraw_amount, "Please enter in an amount less than or equal to #{owed_amount}")
      end
    end
  end
end
