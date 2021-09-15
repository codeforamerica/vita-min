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
      validates_presence_of :bank_name, :account_type, :account_number_confirmation, :routing_number_confirmation
      validates :routing_number, length: { is: 9 }, routing_number: true
      validates :account_number, length: { maximum: 17 }, account_number: true
      validates :my_bank_account, acceptance: { accept: "yes", message: -> (_object, _data) { I18n.t("views.ctc.questions.direct_deposit.my_bank_account.error_message") }}

      def initialize(intake, params = {})
        @bank_account = intake
        super(params)
      end

      def save
        bank_account = @bank_account
        bank_account.assign_attributes(attributes_for(:bank_account))
        bank_account.save if bank_account.valid?
      end
    end
  end
end
