module Portal
  class ClientLoginForm < Form
    attr_accessor :last_four_or_client_id, :possible_clients
    before_validation :possible_clients_present
    validate :last_four_or_client_id_present
    validate :matches_client

    def client
      return unless valid?

      @client
    end

    private

    def matches_client
      if last_four_or_client_id.present?
        @client = possible_clients.find do |client|
          ActiveSupport::SecurityUtils.secure_compare(client.intake&.primary_last_four_ssn.to_s, last_four_or_client_id) ||
            ActiveSupport::SecurityUtils.secure_compare(client.intake&.spouse_last_four_ssn.to_s, last_four_or_client_id) ||
            ActiveSupport::SecurityUtils.secure_compare(client.id.to_s, last_four_or_client_id)
        end
        errors.add(:last_four_or_client_id, I18n.t("portal.client_logins.form.errors.bad_input")) if @client.blank?
      end
    end

    def last_four_or_client_id_present
      if last_four_or_client_id.blank?
        errors.add(:last_four_or_client_id, I18n.t("errors.messages.blank"))
      end
    end

    def possible_clients_present
      raise ArgumentError.new("Form requires at least one possible client.") if possible_clients.blank?
    end
  end
end
