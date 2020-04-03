module AttachmentsHelper
  def download_attachments_to_tmp(documents, file_list: [], &block)
    if documents.blank?
      yield file_list
    else
      documents.first.upload.open(tmpdir: Dir.tmpdir) do |f|
        download_attachments_to_tmp(
          documents[1..-1],
          file_list: file_list.push({file: f, filename: documents.first.upload.filename.to_s}),
          &block
        )
      end
    end
  end
end