module Ctc
  class DirectDepositForm < QuestionsForm
    set_attributes_for :bank_account, :account_type, :bank_name
    set_attributes_for :confirmation, :my_bank_account

    validates_presence_of :account_type, :bank_name
    validates :my_bank_account, acceptance: { accept: "yes", message: -> (_object, _data) { I18n.t("views.ctc.questions.direct_deposit.my_bank_account.error_message_html", link: Ctc::Questions::RefundPaymentController.to_path_helper) } }

    def save
      @intake.update(bank_account_attributes: attributes_for(:bank_account))
    end
    
    def self.existing_attributes(intake)
      return super unless intake.bank_account.present?

      # bank_name is encrypted, but we want it to be editable for clients
      bank_account_attributes = intake.bank_account.attributes.merge(bank_name: intake.bank_account.bank_name)
      HashWithIndifferentAccess.new(intake.attributes.merge(bank_account_attributes))
    end
  end
end
