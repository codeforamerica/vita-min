module ZendeskServiceHelper
  # Zendesk's API requires timezone strings which correspond to items in
  # a drop-down within the app. This is our best effort to convert IANA
  # timezones into that form. Zendesk's timezones appear to be a 100% match
  # for ActiveSupport::TimeZone's `.name` property.
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
    raise NotImplementedError, "You must define #instance in #{self.class.name}"
  end

  def get_end_user(user_id:)
    ZendeskAPI::User.find(client, id: user_id)
  end

  ##
  # find a zendesk ticket by ticket_id
  #
  # @param [Integer] ticket_id the id of the ZendeskAPI::Ticket
  #
  # @return [ZendeskAPI::Ticket, nil] found ticket
  def get_ticket(ticket_id:)
    ZendeskAPI::Ticket.find(client, id: ticket_id)
  end

  ##
  # find a zendesk ticket by ticket_id. raises +MissingTicketError+ if
  # unable to find ticket.
  #
  # @param [Integer] ticket_id the id of the ZendeskAPI::Ticket
  #
  # @return [ZendeskAPI::Ticket, nil] found ticket
  def get_ticket!(ticket_id)
    ZendeskAPI::Ticket.find(client, id: ticket_id) or raise MissingTicketError
  end

  def ticket_url(ticket_id)
    "https://#{EitcZendeskInstance::DOMAIN}.zendesk.com/agent/tickets/#{ticket_id}"
  end

  def search_zendesk_users(query_string)
    client.users.search(query: query_string).to_a!
  end

  def create_or_update_zendesk_user(name: nil, email: nil, phone: nil, time_zone: nil)
    # Ask Zendesk for the best end user by email address and/or phone number. Update its name
    # to the name provided, after qualifying it with `qualify_user_name()`. Update its time zone
    # to the time zone provided, if present.
    #
    # Based on manual testing, if email is absent, Zendesk will always create a new requester.
    if email.blank? && phone.blank?
      raise StandardError.new("Unable to create_or_update_zendesk_user because both phone & email are blank")
    end

    if name.blank?
      raise StandardError.new("Cannot create Zendesk users with a blank name")
    end

    attributes = {
      name: qualify_user_name(name),
      verified: true, # Avoid Zendesk sending a verification email.
    } # see also https://developer.zendesk.com/rest_api/docs/support/users#json-format-for-end-user-requests
    attributes[:time_zone] = time_zone if time_zone.present?
    attributes[:email] = email if email.present?
    attributes[:phone] = phone if phone.present?
    ZendeskAPI::User.create_or_update!(instance.client, attributes).id
  end

  # TODO: find_all_intake_tickets (should filter for only intake tickets if possible)

  def find_latest_ticket(end_user_id)
    end_user = client.user.find(id: end_user_id)
    end_user.requested_tickets(sort_by: :updated_at, sort_order: :desc).first
  end

  def qualified_environments
    %w[development demo staging]
  end

  def qualify_user_name(name)
    qualified_environments.include?(Rails.env) ? "#{name} (Fake User)" : name
  end

  def zendesk_timezone(timezone)
    TIMEZONE_MAP[timezone]
  end

  def test_ticket_tags
    Rails.env.production? ? [] : ["test_ticket"]
  end

  ##
  # builds a +ZendeskAPI::Ticket+ with the specified params
  #
  # @param [String] subject: the subject / title
  # @param [Integer] requester_id: the id of the ZendeskAPI::User
  # @param [Integer] group_id: the id of the Zendesk group the ticket will be
  #                            assigned to
  # @param [Integer] external_id: the id of the local resource (e.g. an intake)
  #                               the ticket concerns
  # @param [String] body: the text of the ticket
  # @param [Hash] fields: additional fields to include as custom fields on the
  #                       ticket
  # @param [Hash] extra_attributes extra attributes for the ZendeskAPI::Ticket's
  #                                constructor
  #
  # @return [ZendeskAPI::Ticket] the ticket (not persisted)
  def build_ticket(subject:, requester_id:, group_id:, external_id: nil, body:, fields: {}, **extra_attributes)
    ZendeskAPI::Ticket.new(
      client,
      subject: subject,
      requester_id: requester_id,
      group_id: group_id,
      external_id: external_id,
      comment: { body: body, public: false },
      fields: [fields],
      **extra_attributes
    )
  end

  ##
  # creates (and persists) a +ZendeskAPI::Ticket+ with the specified params
  #
  # raises a ZendeskAPIError if ticket creation fails
  #
  # @param [String] subject: the subject / title
  # @param [Integer] requester_id: the id of the ZendeskAPI::User
  # @param [Integer] group_id: the id of the Zendesk group the ticket will be
  #                            assigned to
  # @param [Integer] external_id: the id of the local resource (e.g. an intake)
  #                               the ticket concerns
  # @param [String] body: the text of the ticket
  # @param [Hash] fields: additional fields to include as custom fields on the
  #                       ticket
  # @param [Hash] extra_attributes extra attributes for the ZendeskAPI::Ticket's
  #                                constructor
  #
  # @return [ZendeskAPI::Ticket] the (persisted) ticket
  def create_ticket(subject:, requester_id:, group_id:, external_id: nil, body:, fields: {}, **extra_attributes)
    ticket = build_ticket(
      subject: subject,
      requester_id: requester_id,
      group_id: group_id,
      external_id: external_id,
      body: body,
      fields: fields,
      **extra_attributes
    )

    ticket.save!
    ticket
  end

  def assign_ticket_to_group(ticket_id:, group_id:)
    ticket = get_ticket(ticket_id: ticket_id)
    ticket.group_id = group_id
    ticket.save!
  end

  def append_comment_to_ticket(ticket_id:, comment:, fields: {}, tags: [], group_id: nil, skip_if_closed: false)
    raise MissingTicketIdError if ticket_id.blank?

    ticket = get_ticket!(ticket_id)
    return if ticket.status == "closed" && skip_if_closed

    ticket.fields = fields if fields.present?
    ticket.tags += tags if tags.present?
    ticket.group_id = group_id if group_id.present?
    ticket.comment = { body: comment, public: false }
    ticket.save!
  end

  def append_file_to_ticket(ticket_id:, filename:, file:, comment: "", fields: {})
    raise MissingTicketIdError if ticket_id.blank?

    append_multiple_files_to_ticket(
      ticket_id: ticket_id,
      file_list: [{ filename: filename, file: file }],
      comment: comment,
      fields: fields
    )
  end

  # file_list is an Array of Hashes with keys :file and :filename.
  def append_multiple_files_to_ticket(ticket_id:, file_list:, comment: "", fields: {})
    raise MissingTicketIdError if ticket_id.blank?

    ticket = ZendeskAPI::Ticket.find(client, id: ticket_id)
    raise MissingTicketError unless ticket.present?

    ticket.fields = fields if fields.present?
    ticket.comment = {body: comment, public: false}
    file_list.each { |file| append_file_or_add_oversize_comment(file, ticket) }
    ticket.save!
  end

  def append_file_or_add_oversize_comment(file, ticket)
    size = file[:file].size
    if size == 0
      ticket.comment.body.concat("\n\nThe file #{file[:filename]} could not be uploaded because it is empty.")
    elsif size > file_size_limit
      ticket.comment.body.concat("\n\nThe file #{file[:filename]} could not be uploaded because it exceeds the maximum size of #{file_size_limit/1000000}MB.")
    else
      ticket.comment.uploads << file
    end
  end

  def file_size_limit
    if instance == EitcZendeskInstance
      EitcZendeskInstance::MAXIMUM_UPLOAD_SIZE
    else
      UwtsaZendeskInstance::MAXIMUM_UPLOAD_SIZE
    end
  end

  class ZendeskAPIError < StandardError; end
  class ZendeskServiceError < StandardError; end
  class MissingRequesterIdError < ZendeskServiceError; end
  class MissingTicketIdError < ZendeskServiceError; end
  class MissingTicketError < ZendeskServiceError; end
end
