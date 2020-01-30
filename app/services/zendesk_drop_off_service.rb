class ZendeskDropOffService
  include ActiveStorage::Downloading

  # Group IDs
  TAX_HELP_COLORADO = "360007047214"
  GOODWILL_SOUTHERN_RIVERS = "360007941454"
  UNITED_WAY_BAY_AREA = "360007047234"
  ORGANIZATION_GROUP_IDS = {
    "thc" => TAX_HELP_COLORADO,
    "gwisr" => GOODWILL_SOUTHERN_RIVERS,
    "uwba" => UNITED_WAY_BAY_AREA
  }.freeze

  # custom field id codes
  CERTIFICATION_LEVEL = "360028917234"
  INTAKE_SITE = "360028917374"
  STATE = "360028917614"
  INTAKE_STATUS = "360029025294"
  SIGNATURE_METHOD = "360029896814"
  HSA = "360031865033"
  TIMEZONE_MAP = {
    "America/Adak" => "Alaska",
    "America/Anchorage" => "Alaska",
    "America/Boise" => "Mountain Time (US & Canada)",
    "America/Chicago" => "Central Time (US & Canada)",
    "America/Denver" => "Mountain Time (US & Canada)",
    "America/Detroit" => "Eastern Time (US & Canada)",
    "America/Indiana/Indianapolis" => "Eastern Time (US & Canada)",
    "America/Indiana/Knox" => "Central Time (US & Canada)",
    "America/Indiana/Marengo" => "Eastern Time (US & Canada)",
    "America/Indiana/Petersburg" => "Eastern Time (US & Canada)",
    "America/Indiana/Tell_City" => "Central Time (US & Canada)",
    "America/Indiana/Vevay" => "Eastern Time (US & Canada)",
    "America/Indiana/Vincennes" => "Eastern Time (US & Canada)",
    "America/Indiana/Winamac" => "Eastern Time (US & Canada)",
    "America/Juneau" => "Alaska",
    "America/Kentucky/Louisville" => "Eastern Time (US & Canada)",
    "America/Kentucky/Monticello" => "Eastern Time (US & Canada)",
    "America/Los_Angeles" => "Pacific Time (US & Canada)",
    "America/Menominee" => "Central Time (US & Canada)",
    "America/Metlakatla" => "Alaska",
    "America/New_York" => "Eastern Time (US & Canada)",
    "America/Nome" => "Alaska",
    "America/North_Dakota/Beulah" => "Central Time (US & Canada)",
    "America/North_Dakota/Center" => "Central Time (US & Canada)",
    "America/North_Dakota/New_Salem" => "Central Time (US & Canada)",
    "America/Phoenix" => "Arizona",
    "America/Sitka" => "Alaska",
    "America/Yakutat" => "Alaska",
    "Pacific/Honolulu" => "Hawaii",
  }

  def initialize(drop_off)
    @drop_off = drop_off
  end

  def create_ticket
    zendesk_user = find_or_create_end_user(@drop_off.name, @drop_off.email, @drop_off.phone_number)
    ticket = ZendeskAPI::Ticket.new(
      client,
      subject: @drop_off.name,
      requester_id: zendesk_user.id,
      group_id: group_id,
      comment: { body: comment_body },
      fields: [
        {
          CERTIFICATION_LEVEL => @drop_off.certification_level,
          HSA => @drop_off.hsa,
          INTAKE_SITE => intake_site_tag,
          STATE => @drop_off.state,
          INTAKE_STATUS => "3._ready_for_prep",
          SIGNATURE_METHOD => @drop_off.signature_method
        },
      ]
    )
    attach_file_and_save_ticket(ticket)
    return ticket.id
  end

  def append_to_existing_ticket
    ticket = ZendeskAPI::Ticket.find(client, id: @drop_off.zendesk_ticket_id)
    ticket.comment = { body: comment_body }

    attach_file_and_save_ticket(ticket)
  end

  def search_zendesk_users(query_string)
    client.users.search(query: query_string).to_a
  end

  def find_end_user(name, email, phone)
    if email.present?
      email_matches = search_zendesk_users("email:#{email}")
      return email_matches.first if email_matches.present?
    end

    search_string = "name:\"#{name}\""
    search_string += " phone:#{phone}" if phone.present?
    results = search_zendesk_users(search_string)
    results.first
  end

  def find_or_create_end_user(name, email, phone)
    user = find_end_user(name, email, phone)
    return user if user.present?

    client.users.create(name: name, email: email, phone: phone, verified: true, time_zone: zendesk_timezone)
  end

  def comment_body
    <<~BODY
      New Dropoff at #{@drop_off.intake_site}

      Certification Level: #{@drop_off.certification_level}#{" and HSA" if @drop_off.hsa}
      Name: #{@drop_off.name}
      Phone number: #{@drop_off.formatted_phone_number}
      Email: #{@drop_off.email}
      Signature method: #{@drop_off.formatted_signature_method}#{pickup_date_line}
      State (for state tax return): #{@drop_off.state_name}
      Additional info: #{@drop_off.additional_info}
    BODY
  end

  def file_upload_name
    file_extension = @drop_off.document_bundle.blob.filename.extension
    "#{@drop_off.name.split.join}.#{file_extension}"
  end

  private

  def attach_file_and_save_ticket(ticket)
    download_blob_to_tempfile do |file|
      ticket.comment.uploads << {file: file, filename: file_upload_name}
      ticket.save
    end
  end

  def blob
    @drop_off.document_bundle.blob
  end

  def zendesk_timezone
    TIMEZONE_MAP.fetch(@drop_off.timezone, "Mountain Time (US & Canada)")
  end

  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = "https://#{Rails.application.credentials.dig(:zendesk, :url)}/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :api_key)
    end
  end

  def intake_site_tag
    @drop_off.intake_site.downcase.gsub(" ", "_").gsub("-", "_")
  end

  def pickup_date_line
    "\nPickup Date: #{I18n.l(@drop_off.pickup_date)}" if @drop_off.pickup_date
  end

  def group_id
    ORGANIZATION_GROUP_IDS[@drop_off.organization]
  end
end