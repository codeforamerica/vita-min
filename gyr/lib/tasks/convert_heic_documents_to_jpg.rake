namespace :documents do
  desc "Converts existing documents with heic attachments to jpg"
  task convert_heic_to_jpg: [:environment] do
    Document.where.not(client: nil).find_each do |document|
      if document.upload.present? && document.upload.filename.extension_without_delimiter.downcase == "heic"
        puts "Converting document #{document.id}"
        begin
          document.convert_heic_upload_to_jpg!
        rescue StandardError
          # Empirically, there are HEIC files on demo that fail to convert on demo
          # but seem to convert fine on development workstations.
          puts("[E] Unable to convert")
        end
      end
    end
  end
end
