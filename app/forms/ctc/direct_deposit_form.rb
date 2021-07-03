module Ctc
  class DirectDepositForm < QuestionsForm
    set_attributes_for :intake, :bank_account_type, :bank_name
    set_attributes_for :confirmation, :my_bank_account

    validates_presence_of :bank_account_type, :bank_name
    validates :my_bank_account, acceptance: { accept: "yes", message: I18n.t("views.ctc.questions.direct_deposit.my_bank_account.error_message_html", link: Rails.application.routes.url_helpers.questions_refund_payment_path) }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end