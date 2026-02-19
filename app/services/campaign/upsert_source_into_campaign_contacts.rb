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
      latest_signup_at: nil,
      latest_gyr_intake_at: nil,
      locale: nil
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
      @latest_signup_at = latest_signup_at
      @latest_gyr_intake_at = latest_gyr_intake_at
    end

    def call
      contact = find_contact || CampaignContact.new

      contact.email_address = @email unless @email.blank?
      contact.sms_phone_number = @phone unless @phone.blank?
      contact.first_name = format_name(choose_name(contact.first_name, @first_name, source: @source))
      contact.last_name = format_name(choose_name(contact.last_name, @last_name, source: @source))
      contact.email_notification_opt_in = contact.email_notification_opt_in || @email_opt_in
      contact.sms_notification_opt_in = contact.sms_notification_opt_in || @sms_opt_in
      contact.locale = @locale.presence || contact.locale.presence || "en"

      if @latest_signup_at.present?
        contact.latest_signup_at = [contact.latest_signup_at, @latest_signup_at].compact.max
      end

      if @latest_gyr_intake_at.present?
        contact.latest_gyr_intake_at = [contact.latest_gyr_intake_at, @latest_gyr_intake_at].compact.max
      end

      case @source
      when :gyr
        contact.gyr_intake_ids = ((contact.gyr_intake_ids || []) + [@source_id]).uniq
      when :signup
        contact.sign_up_ids = ((contact.sign_up_ids || []) + [@source_id]).uniq
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