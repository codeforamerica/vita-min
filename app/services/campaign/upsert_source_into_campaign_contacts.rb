module Campaign
  class UpsertSourceIntoCampaignContacts
    def self.call(**kwargs)
      new(**kwargs).call
    end

    def initialize(
      source:, source_id:,
      first_name:, last_name:,
      email:, phone:,
      email_opt_in:, sms_opt_in:,
      locale: "en", state_file_ref: nil,
      suppressed_for_gyr_product_year: nil
    )
      @source = source
      @source_id = source_id
      @first_name = first_name
      @last_name = last_name
      @email = email
      @phone = phone
      @email_opt_in = email_opt_in
      @sms_opt_in = sms_opt_in
      @locale = locale
      @state_file_ref = state_file_ref
      @suppressed_for_gyr_product_year = suppressed_for_gyr_product_year
    end

    def call
      contact = find_contact || CampaignContact.new

      contact.email_address = @email unless @email.blank?
      contact.sms_phone_number = @phone unless @phone.blank?
      contact.first_name = format_name(choose_name(contact.first_name, @first_name, source: @source))
      contact.last_name = format_name(choose_name(contact.last_name, @last_name, source: @source))
      contact.email_notification_opt_in = contact.email_notification_opt_in || @email_opt_in
      contact.sms_notification_opt_in = contact.sms_notification_opt_in || @sms_opt_in
      contact.locale = @locale unless @locale.blank?
      contact.suppressed_for_gyr_product_year = @suppressed_for_gyr_product_year unless nil

      case @source
      when :gyr
        contact.gyr_intake_ids = ((contact.gyr_intake_ids || []) + [@source_id]).uniq
      when :signup
        contact.sign_up_ids = ((contact.sign_up_ids || []) + [@source_id]).uniq
      end

      if @state_file_ref.present?
        refs = contact.state_file_intake_refs || []
        refs << @state_file_ref unless refs.any? { |r| r["id"] == @state_file_ref[:id] && r["type"] == @state_file_ref[:type] }
        contact.state_file_intake_refs = refs
      end

      contact.tap(&:save!)
    end

    private

    def format_name(name)
      name.to_s.strip.tr("_", " ").squeeze(" ").split.map(&:capitalize).join(" ").presence
    end

    def find_contact
      return CampaignContact.find_by(email_address: @email) if @email.present?

      return unless @phone.present?
      return if @email_opt_in

      CampaignContact.find_by(sms_phone_number: @phone, email_address: nil)
    end

    def choose_name(existing, incoming, source:)
      return existing if incoming.blank?
      return incoming if existing.blank?
      source == :signup ? existing : incoming
    end
  end
end