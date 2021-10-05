module Ctc
  class BankAccountForm < Form
    include FormAttributes

    set_attributes_for :bank_account,
                       :bank_name,
                       :routing_number,
                       :account_number,
                       :account_type
    set_attributes_for :confirmation, :my_bank_account, :routing_number_confirmation, :account_number_confirmation
    set_attributes_for :recaptcha, :recaptcha_score, :recaptcha_action

    with_options if: -> { (account_number.present? && account_number != @bank_account&.account_number) || account_number_confirmation.present? } do
      validates :account_number, confirmation: true
      validates :account_number_confirmation, presence: true
    end

    with_options if: -> { (routing_number.present? && routing_number != @bank_account&.routing_number) || routing_number_confirmation.present? } do
      validates :routing_number, confirmation: true
      validates :routing_number_confirmation, presence: true
    end

    validates_presence_of :bank_name, :account_type
    validates :routing_number, length: { is: 9 }, routing_number: true
    validates :account_number, length: { maximum: 17 }, account_number: true
    validates :my_bank_account, acceptance: { accept: "yes", message: -> (_object, _data) { I18n.t("views.ctc.questions.direct_deposit.my_bank_account.error_message") }}

    def self.from_bank_account(bank_account)
      new(bank_account, existing_attributes(bank_account, Attributes.new(scoped_attributes[:bank_account]).to_sym))
    end

    def initialize(bank_account, params = {})
      @bank_account = bank_account
      super(params)
    end

    def save
      @bank_account.assign_attributes(attributes_for(:bank_account))

      if @bank_account.valid?
        @bank_account.save
        @bank_account.intake.update(refund_payment_method: "direct_deposit")
      end

      if attributes_for(:recaptcha)[:recaptcha_score].present?
        @bank_account.intake.client.recaptcha_scores.create(
          score: attributes_for(:recaptcha)[:recaptcha_score],
          action: attributes_for(:recaptcha)[:recaptcha_action]
        )
      end
    end

    def self.existing_attributes(model, attribute_keys)
      HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, model.send(k)] }].merge(
        my_bank_account: model.persisted? ? true : false
      )
    end
    private_class_method :existing_attributes
  end
end
