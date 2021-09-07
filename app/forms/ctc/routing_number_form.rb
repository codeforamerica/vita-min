module Ctc
  class RoutingNumberForm < QuestionsForm
    set_attributes_for :bank_account, :routing_number
    set_attributes_for :confirmation, :routing_number_confirmation

    validates :routing_number, routing_number: true, confirmation: true, presence: true, length: { is: 9 }
    validates :routing_number_confirmation, presence: true

    def save
      @intake.bank_account.update(attributes_for(:bank_account))
    end
  end
end