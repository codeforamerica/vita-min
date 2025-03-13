module StateFile
  class TaxesOwedForm < TaxRefundForm
    attr_accessor :app_time

    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :withdraw_amount

    set_attributes_for :confirmation,
                       :routing_number_confirmation,
                       :account_number_confirmation

    set_attributes_for :date,
                       :date_electronic_withdrawal_month,
                       :date_electronic_withdrawal_year,
                       :date_electronic_withdrawal_day

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validates :withdraw_amount, presence: true, numericality: { greater_than: 0 }
      validate :withdraw_amount_does_not_exceed_owed_amount
      with_options if: -> { form_submitted_before_payment_deadline? } do
        validate :date_electronic_withdrawal_is_valid_date
        validate :withdrawal_date_within_range
      end
    end

    def initialize(intake = nil, params = nil)
      @timezone = StateFile::StateInformationService.timezone(intake.state_code)
      app_time = params[:app_time].present? ? params[:app_time] : Time.current
      @form_submitted_time = app_time.in_time_zone(@timezone)
      super(intake, params)
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

    def form_submitted_before_payment_deadline?
      @form_submitted_time.to_date.before?(StateInformationService.payment_deadline_date(intake.state_code))
    end

    def date_electronic_withdrawal
      # Future story: set this during submission bundle instead, using submission date
      return @form_submitted_time.to_date unless form_submitted_before_payment_deadline?

      parse_date_params(date_electronic_withdrawal_year,
                        date_electronic_withdrawal_month,
                        date_electronic_withdrawal_day)&.to_date
    end

    def date_electronic_withdrawal_is_valid_date
      return true unless form_submitted_before_payment_deadline?

      valid_text_date(date_electronic_withdrawal_year,
                      date_electronic_withdrawal_month,
                      date_electronic_withdrawal_day,
                      :date_electronic_withdrawal)
    end

    def withdrawal_date_within_range
      return true unless form_submitted_before_payment_deadline?
      return false if date_electronic_withdrawal.nil?

      payment_deadline = StateInformationService.payment_deadline_date(intake.state_code)
      if date_electronic_withdrawal.before?(@form_submitted_time.to_date) ||
         date_electronic_withdrawal.after?(payment_deadline)
        self.errors.add(:date_electronic_withdrawal,
                        I18n.t("forms.errors.taxes_owed.withdrawal_date_deadline",
                               payment_deadline_date: I18n.l(payment_deadline.to_date, format: :medium, locale: intake&.locale),
                               payment_deadline_year: payment_deadline.year))
      end
    end

    def withdraw_amount_does_not_exceed_owed_amount
      owed_amount = intake&.calculated_refund_or_owed_amount&.abs
      return unless self.withdraw_amount.to_i > owed_amount

      self.errors.add(:withdraw_amount,
                      I18n.t("forms.errors.taxes_owed.withdraw_amount_higher_than_owed", owed_amount: owed_amount))
    end
  end
end
