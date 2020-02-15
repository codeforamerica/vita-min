module ZendeskServiceHelper
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
  }.freeze

  def client
    @client ||= instance.client
  end

  def instance
    EitcZendeskInstance
  end

  def search_zendesk_users(query_string)
    client.users.search(query: query_string).to_a
  end

  def find_end_user(name, email, phone, exact_match: false)
    if email.present?
      email_matches = search_zendesk_users("email:#{email}")
      return email_matches.first&.id if email_matches.present?
    end

    search_string = "name:\"#{name}\""
    search_string += " phone:#{phone}" if phone.present?
    results = search_zendesk_users(search_string)
    if exact_match
      results = results.select { |result| result.email.blank? } if email.blank?
      results = results.select { |result| result.phone.blank? } if phone.blank?
    end
    results.first&.id
  end

  def create_end_user(name:, **attributes)
    # for a list of possible valid attributes, see:
    #   https://developer.zendesk.com/rest_api/docs/support/users#json-format-for-end-user-requests
    client.users.create(name: name, verified: true, **attributes)
  end

  def find_or_create_end_user(name, email, phone, exact_match: false, time_zone: nil)
    user = find_end_user(name, email, phone, exact_match: exact_match)
    return user if user.present?

    result = create_end_user(name: name, email: email, phone: phone, time_zone: time_zone)
    result.id if result.present?
  end

  def build_ticket(subject:, requester_id:, group_id:, body:, fields: {})
    ZendeskAPI::Ticket.new(
      client,
      subject: subject,
      requester_id: requester_id,
      group_id: group_id,
      comment: { body: body },
      fields: [fields]
    )
  end

  def create_ticket(subject:, requester_id:, group_id:, body:, fields: {})
    ticket = build_ticket(
      subject: subject,
      requester_id: requester_id,
      group_id: group_id,
      body: body,
      fields: fields
    )
    ticket.save
    ticket.id
  end

  def append_file_to_ticket(ticket_id:, filename:, file:, comment: "")
    raise MissingTicketIdError if ticket_id.blank?

    ticket = ZendeskAPI::Ticket.find(client, id: ticket_id)
    ticket.comment = { body: comment }
    ticket.comment.uploads << {file: file, filename: filename}
    ticket.save
  end

  class ZendeskServiceError < StandardError; end
  class MissingRequesterIdError < ZendeskServiceError; end
  class MissingTicketIdError < ZendeskServiceError; end
end