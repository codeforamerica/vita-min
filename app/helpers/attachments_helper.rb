module AttachmentsHelper
  # @param [Array<ActiveStorage::Attached>] attachments Array of attachment objects, e.g. @intake.documents.map(&:upload)
  def download_attachments_to_tmp(attachments, file_list: [], &block)
    if attachments.blank?
      yield file_list
    else
      attachments.first.open(tmpdir: Dir.tmpdir) do |f|
        download_attachments_to_tmp(
          attachments[1..-1],
          file_list: file_list.push({ file: f, filename: attachments.first.filename.to_s }),
          &block
        )
      end
    end
  end
end