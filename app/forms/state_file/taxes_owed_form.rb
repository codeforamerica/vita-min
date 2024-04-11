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

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validate :date_electronic_withdrawal_is_valid_date
      validate :withdrawal_date_before_deadline, if: -> { date_electronic_withdrawal.present? }
      validates :withdraw_amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
      validate :withdraw_amount_higher_than_owed?
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
      attributes
    end

    private

    def date_electronic_withdrawal
      parse_date_params(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day)
    end

    def date_electronic_withdrawal_is_valid_date
      valid_text_date(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day, :date_electronic_withdrawal)
    end

    def withdraw_amount_higher_than_owed?
      owed_amount = intake.calculated_refund_or_owed_amount.abs
      if self.withdraw_amount.to_i > owed_amount
        self.errors.add(
          :withdraw_amount,
          I18n.t("forms.errors.taxes_owed.withdraw_amount_higher_than_owed", owed_amount: owed_amount)
        )
      end
    end

    def withdrawal_date_before_deadline
      unless date_electronic_withdrawal.between?(DateTime.current.to_date, withdrawal_date_deadline)
        self.errors.add(:date_electronic_withdrawal, I18n.t("forms.errors.taxes_owed.withdrawal_date_deadline", year: withdrawal_date_deadline.year))
      end
    end

    def withdrawal_date_deadline
      DateTime.parse("April 15th, #{MultiTenantService.new(:statefile).current_tax_year + 1}")
    end
  end
end
