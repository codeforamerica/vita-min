module StateFile
  class TaxesOwedForm < TaxRefundForm
    include DateHelper
    include DateAccessible
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
    # Position is important. Must be below `set_attributes_for` to overwrite the standard `attr_accessor`s
    date_accessor :date_electronic_withdrawal

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validates :date_electronic_withdrawal,
                inclusion: {
                  in: Date.parse(app_time)..state_specific_payment_deadline(intake.state_code),
                  message: lambda { |_object, _data|
                    I18n.t("forms.errors.taxes_owed.withdrawal_date_deadline",
                           payment_deadline_date: I18n.l(payment_deadline.to_date, format: :medium, locale: intake.locale),
                           payment_deadline_year: payment_deadline.year)
                  },
                  presence: true, unless: -> { app_time.after?(payment_deadline) }
                }
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
      if app_time.before?(payment_deadline)
        date_electronic_withdrawal
      else
        # TODO: Does NC need us to increment this date if it breaks business rules?
        app_time.in_time_zone(StateFile::StateInformationService.timezone(state_code))
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
  end
end
