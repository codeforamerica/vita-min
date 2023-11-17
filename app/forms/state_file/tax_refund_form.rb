module StateFile
  class TaxRefundForm < QuestionsForm
    include DateHelper
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :bank_name

    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation

    validates :payment_or_deposit_type, presence: true
    validates :bank_name, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validates :account_type, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validates :routing_number, presence: true, length: {is: 9}, unless: -> { payment_or_deposit_type == "mail" }
    validates :routing_number_confirmation, presence: true, length: {is: 9}, unless: -> { payment_or_deposit_type == "mail" }
    validates :account_number, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    validates :account_number_confirmation, presence: true, unless: -> { payment_or_deposit_type == "mail" }

    with_options if: -> { (account_number.present? && account_number != @intake.account_number) || account_number_confirmation.present? } do
      validates :account_number, confirmation: true, unless: -> { payment_or_deposit_type == "mail" }
      validates :account_number_confirmation, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    end

    with_options if: -> { (routing_number.present? && routing_number != @intake.routing_number) || routing_number_confirmation.present? } do
      validates :routing_number, confirmation: true, unless: -> { payment_or_deposit_type == "mail" }
      validates :routing_number_confirmation, presence: true, unless: -> { payment_or_deposit_type == "mail" }
    end

    def save
      @intake.update!(attributes_for(:intake))
    end

    def self.existing_attributes(intake)
      attributes = super
      attributes.except(:routing_number, :account_number, :routing_number_confirmation, :account_number_confirmation)
    end

  end
end
