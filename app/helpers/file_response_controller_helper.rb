module FileResponseControllerHelper
  def render_pdf(pdf_file)
    send_data(pdf_file.read, type: "application/pdf", disposition: "inline")
  end

  def render_active_storage_attachment(attachment)
    send_data(attachment.download, type: attachment.content_type, disposition: "inline")
  end
end