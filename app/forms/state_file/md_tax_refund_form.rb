module StateFile
  class MdTaxRefundForm < QuestionsForm
    include DateHelper
    set_attributes_for :intake,
                       :payment_or_deposit_type,
                       :routing_number,
                       :account_number,
                       :account_type,
                       :account_holder_name,
                       :joint_account_holder_name,
                       :bank_authorization_confirmed
    set_attributes_for :confirmation, :routing_number_confirmation, :account_number_confirmation

    validates :payment_or_deposit_type, presence: true

    with_options unless: -> { payment_or_deposit_type == "mail" } do
      validates :account_holder_name, presence: true

      validates :account_type, presence: true

      validates :account_number, presence: true, confirmation: true, length: { in: 5..17 }, numericality: true
      validates :account_number_confirmation, presence: true

      validates :routing_number, presence: true, confirmation: true, routing_number: true
      validates :routing_number_confirmation, presence: true

      validates :bank_authorization_confirmed, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("state_file.questions.md_tax_refund.md_bank_details.bank_authorization_confirmation_error") }}

      with_options if: -> { account_number.present? && routing_number.present? } do
        validate :bank_numbers_not_equal
      end
    end

    def save
      @intake.update!(attributes_for(:intake))
    end

    def self.existing_attributes(intake)
      attributes = super
      attributes.except(:routing_number, :account_number, :routing_number_confirmation, :account_number_confirmation)
    end

    private

    def bank_numbers_not_equal
      if routing_number == account_number
        errors.add(:account_number, I18n.t("forms.errors.routing_account_number.not_same"))
        errors.add(:routing_number, I18n.t("forms.errors.routing_account_number.not_same"))
      end
    end
  end
end
