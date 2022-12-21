module Ctc
  class AccountNumberForm < QuestionsForm
    set_attributes_for :bank_account, :account_number
    set_attributes_for :confirmation, :account_number_confirmation

    validates :account_number, presence: true, confirmation: true, length: { maximum: 17 }, account_number: true
    validates :account_number_confirmation, presence: true

    def save
      @intake.bank_account.update(attributes_for(:bank_account))
    end
  end
end