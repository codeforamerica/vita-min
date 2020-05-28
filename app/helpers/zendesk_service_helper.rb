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
    client.users.search(query: query_string).to_a
  end

  def find_end_user(name, email, phone, exact_match: false)
    if email.present?
      email_matches = search_zendesk_users("email:#{email}")
      if email_matches.present?
        return email_matches.first
      elsif exact_match
        return nil
      end
    end

    search_string = ""
    search_string += "name:\"#{qualify_user_name(name)}\" " if name.present?
    search_string += "phone:#{phone}" if phone.present?
    results = search_zendesk_users(search_string)
    if exact_match
      results = results.select { |result| result.name.blank? } if name.blank?
      results = results.select { |result| result.email.blank? } if email.blank?
      results = results.select { |result| result.phone.blank? } if phone.blank?
    end
    results.first
  end

  # TODO: find_all_intake_tickets (should filter for only intake tickets if possible)

  def find_latest_ticket(end_user_id)
    end_user = client.user.find(id: end_user_id)
    end_user.requested_tickets(sort_by: :updated_at, sort_order: :desc).first
  end

  def create_end_user(name:, **attributes)
    # for a list of possible valid attributes, see:
    #   https://developer.zendesk.com/rest_api/docs/support/users#json-format-for-end-user-requests
    client.users.create(name: qualify_user_name(name), verified: true, **attributes)
  end

  def find_or_create_end_user(name, email, phone, exact_match: false, time_zone: nil)
    user = find_end_user(name, email, phone, exact_match: exact_match)
    if user.present?
      update_user_contact_info(user, phone)
      return user.id
    end

    result = create_end_user(name: name, email: email, phone: phone, time_zone: time_zone)
    result.id if result.present?
  end

  def qualified_environments
    %w[development demo staging]
  end

  def qualify_user_name(name)
    qualified_environments.include?(Rails.env) ? "#{name} (Fake User)" : name
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
      comment: { body: body },
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

    unless ticket.save
      raise ZendeskAPIError.new("Error creating Zendesk Ticket: #{ticket.errors}")
    end

    ticket
  end

  def assign_ticket_to_group(ticket_id:, group_id:)
    ticket = get_ticket(ticket_id: ticket_id)
    ticket.group_id = group_id
    success = ticket.save

    unless success
      raise ZendeskAPIError.new("Error assigning ticket to group: #{ticket.errors}")
    end

    success
  end

  def append_comment_to_ticket(ticket_id:, comment:, fields: {}, public: false, group_id: nil)
    raise MissingTicketIdError if ticket_id.blank?

    ticket = get_ticket!(ticket_id)
    ticket.fields = fields if fields.present?
    ticket.group_id = group_id if group_id.present?
    ticket.comment = { body: comment, public: public }
    success = ticket.save

    unless success
      raise ZendeskAPIError.new("Error appending comment to ticket: #{ticket.errors}")
    end

    success
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
    ticket.comment = {body: comment}
    file_list.each { |file| append_file_or_add_oversize_comment(file, ticket) }
    success = ticket.save

    unless success
      raise ZendeskAPIError.new("Error appending file to ticket: #{ticket.errors}")
    end

    success
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

  private

  def update_user_contact_info(user, phone)
    if phone && user.phone.blank?
      user.phone = phone
      user.save
    end
  end
end
