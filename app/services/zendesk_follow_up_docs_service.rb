class ZendeskFollowUpDocsService
  include ZendeskServiceHelper

  def initialize(intake)
    @intake = intake
  end

  def send_requested_docs
    return if @intake.documents.none?

    new_requested_docs = @intake.documents.where(document_type: "Requested", zendesk_ticket_id: nil)
    file_list = new_requested_docs.map do |document|
      @document_blob = document.upload
      blob.open(tmpdir: Dir.tmpdir) do |file|
        {file: file, filename: document.upload.filename.to_s}
      end
    end

    output = append_multiple_files_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      file_list: file_list,
      comment: "The client added requested follow-up documents:\n" + new_requested_docs.map { |d| "* #{d.upload.filename}\n" }.join,
    )

    raise CouldNotSendFollowUpDocError unless output
    new_requested_docs.each { |doc| doc.update(zendesk_ticket_id: @intake.intake_ticket_id) }
    output
  ensure
    if file_list.present?
      file_list.each { |entry| entry[:file].close! }
    end
  end

  def blob
    @document_blob
  end

  class CouldNotSendFollowUpDocError < ZendeskServiceError; end
end
