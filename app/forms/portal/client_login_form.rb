module Portal
  class ClientLoginForm < Form
    attr_accessor :number, :possible_clients
    before_validation :possible_clients_present
    validate :number_present
    validate :matches_client

    def client
      return unless valid?

      @client
    end

    private

    def matches_client
      if number.present?
        @client = possible_clients.find do |client|
          ActiveSupport::SecurityUtils.secure_compare(client.intake&.primary_last_four_ssn.to_s, number) ||
            ActiveSupport::SecurityUtils.secure_compare(client.intake&.spouse_last_four_ssn.to_s, number) ||
            ActiveSupport::SecurityUtils.secure_compare(client.id.to_s, number)
        end
        errors.add(:number, I18n.t("portal.client_logins.form.errors.bad_input")) if @client.blank?
      end
    end

    def number_present
      if number.blank?
        errors.add(:number, I18n.t("errors.messages.blank"))
      end
    end

    def possible_clients_present
      raise ArgumentError.new("Form requires at least one possible client.") if possible_clients.blank?
    end
  end
end
