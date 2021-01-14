module Portal
  class ClientLoginForm < Form
    attr_accessor :last_four, :confirmation_number, :possible_clients
    before_validation :possible_clients_present
    validate :last_four_or_confirmation_number_present
    validate :matches_client

    def client
      return unless valid?

      @client
    end

    private

    def matches_client
      if last_four.present?
        @client = possible_clients.find do |client|
          primary_match = ActiveSupport::SecurityUtils.secure_compare(client.intake&.primary_last_four_ssn.to_s, last_four)
          spouse_match = ActiveSupport::SecurityUtils.secure_compare(client.intake&.spouse_last_four_ssn.to_s, last_four)
          primary_match || spouse_match
        end
        errors.add(:last_four, I18n.t("portal.client_logins.form.errors.bad_last_four")) if @client.blank?
      elsif confirmation_number.present?
        @client = possible_clients.find_by(id: confirmation_number)
        errors.add(:confirmation_number, I18n.t("portal.client_logins.form.errors.bad_confirmation_number")) if @client.blank?
      end
    end

    def last_four_or_confirmation_number_present
      if last_four.blank? && confirmation_number.blank?
        errors.add(:confirmation_number, I18n.t("portal.client_logins.form.errors.at_least_one"))
      end
    end

    def possible_clients_present
      raise ArgumentError.new("Form requires at least one possible client.") if possible_clients.blank?
    end
  end
end