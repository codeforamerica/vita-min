class ZendeskDropOffService
  include ZendeskServiceHelper
  include ActiveStorage::Downloading

  # Group IDs
  ORGANIZATION_GROUP_IDS = {
    "thc" => EitcZendeskInstance::TAX_HELP_COLORADO,
    "gwisr" => EitcZendeskInstance::GOODWILL_SOUTHERN_RIVERS,
    "uwba" => EitcZendeskInstance::UNITED_WAY_BAY_AREA
  }.freeze

  def initialize(drop_off)
    @drop_off = drop_off
  end

  def create_ticket_and_attach_file
    zendesk_user_id = find_or_create_end_user(@drop_off.name, @drop_off.email, @drop_off.phone_number)
    ticket = build_ticket(
      subject: @drop_off.name,
      requester_id: zendesk_user_id,
      group_id: group_id,
      external_id: @drop_off.external_id,
      body: comment_body,
      fields: {
          EitcZendeskInstance::CERTIFICATION_LEVEL => @drop_off.certification_level,
          EitcZendeskInstance::HSA => @drop_off.hsa,
          EitcZendeskInstance::INTAKE_SITE => intake_site_tag,
          EitcZendeskInstance::STATE => @drop_off.state,
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          EitcZendeskInstance::SIGNATURE_METHOD => @drop_off.signature_method
      }
    )
    attach_file_and_save_ticket(ticket)
    return ticket.id
  end

  def append_to_existing_ticket
    ticket = ZendeskAPI::Ticket.find(client, id: @drop_off.zendesk_ticket_id)
    ticket.comment = { body: comment_body }

    attach_file_and_save_ticket(ticket)
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
      success = ticket.save

      unless success
        raise ZendeskServiceHelper::ZendeskAPIError.new("Error attaching file: #{ticket.errors}")
      end

      success
    end
  end

  def blob
    @drop_off.document_bundle.blob
  end

  def zendesk_timezone
    TIMEZONE_MAP.fetch(@drop_off.timezone, "Mountain Time (US & Canada)")
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
