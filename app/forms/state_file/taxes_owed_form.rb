module StateFile
  class TaxesOwedForm < TaxRefundForm
    include DateHelper
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :withdraw_amount

    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation
    set_attributes_for :date,
                       :date_electronic_withdrawal_month,
                       :date_electronic_withdrawal_year,
                       :date_electronic_withdrawal_day,
                       :app_time

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validate :date_electronic_withdrawal_is_valid_date
      validate :withdrawal_date_within_range, if: -> { date_electronic_withdrawal.present? }
      validate :withdrawal_date_intake_validations, if: -> { date_electronic_withdrawal.present? }
      validates :withdraw_amount, presence: true, numericality: { greater_than: 0 }
      validate :withdraw_amount_higher_than_owed?
    end

    def save
      attrs = attributes_for(:intake)
      @intake.update(attrs.merge(date_electronic_withdrawal: date_electronic_withdrawal))
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
      if (app_time || Time.current).before?(state_specific_payment_deadline(@intake&.state_code))
        # TODO: set the time to be within the State's timezone on the selected day
        parse_date_params(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day)
      else
        app_time.in_time_zone(StateFile::StateInformationService.timezone(@intake&.state_code))
      end
    end

    def date_electronic_withdrawal_is_valid_date
      if app_time.before?(state_specific_payment_deadline(@intake&.state_code))
        valid_text_date(date_electronic_withdrawal_year,
                        date_electronic_withdrawal_month,
                        date_electronic_withdrawal_day,
                        :date_electronic_withdrawal)
      else
        true
      end
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

    def withdrawal_date_within_range
      payment_deadline = state_specific_payment_deadline(intake&.state_code)
      if date_electronic_withdrawal < app_time || date_electronic_withdrawal > payment_deadline
        self.errors.add(:date_electronic_withdrawal,
                        I18n.t("forms.errors.taxes_owed.withdrawal_date_deadline",
                               payment_deadline_date: I18n.l(payment_deadline.to_date, format: :medium, locale: intake&.locale),
                               payment_deadline_year: payment_deadline.year))
      end
    end

    def withdrawal_date_intake_validations
      @intake.date_electronic_withdrawal = date_electronic_withdrawal
      @intake.validate(:date_electronic_withdrawal)
      if @intake.errors[:date_electronic_withdrawal].present?
        errors.add(:date_electronic_withdrawal, @intake.errors[:date_electronic_withdrawal])
      end
    end
  end
end
