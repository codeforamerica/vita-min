module Ctc
  module Portal
    class BankAccountForm < Form
      include FormAttributes

      set_attributes_for :bank_account,
                         :bank_name,
                         :routing_number,
                         :account_number,
                         :account_type
      set_attributes_for :confirmation, :my_bank_account, :routing_number_confirmation, :account_number_confirmation

      validates_confirmation_of :account_number, :routing_number
      validates_presence_of :account_number_confirmation, :routing_number_confirmation
      validates :routing_number, length: { is: 9 }, routing_number: true
      validates :account_number, length: { maximum: 17 }, account_number: true
      validates :my_bank_account, acceptance: { accept: "yes", message: -> (_object, _data) { I18n.t("views.ctc.questions.direct_deposit.my_bank_account.error_message") }}

      def initialize(intake, params = {})
        @intake = intake
        super(params)
      end

      def save
        bank_account = @intake.bank_account || @intake.build_bank_account
        bank_account.assign_attributes(attributes_for(:bank_account))
        bank_account.save if bank_account.valid?
      end

      private

      def birth_date
        parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
      end

      def birth_date_is_valid_date
        valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, :birth_date)
      end
    end
  end
end
