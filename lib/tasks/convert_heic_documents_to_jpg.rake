namespace :documents do
  desc "Converts existing documents with heic attachments to jpg"
  task convert_heic_to_jpg: [:environment] do
    Document.find_each do |document|
      if document.upload.filename.extension_without_delimiter.downcase == "heic"
        puts "Converting document #{document.id}"
        document.convert_heic_upload_to_jpg!
      end
    end
  end
end
