class FileTypeAllowedValidator < ActiveModel::EachValidator
  # The list of allowed types is security sensitive because it may allow files with script
  # capabilities to be uploaded leading to XSS attacks. Please be sure to know what you are
  # doing when modifying this list.
  VALID_FILE_EXTENSIONS = [".jpg", ".jpeg", ".pdf", ".png", ".heic", ".bmp", ".txt", ".tiff", ".gif"]
  VALID_MIME_TYPES = ["image/jpeg", "image/png", "application/pdf", "image/heic", "image/bmp", "text/plain", "image/tiff", "image/gif"]

  def validate_each(record, attr_name, value)
    return if !value

    extension = File.extname(value.path)
    unless VALID_FILE_EXTENSIONS.include?(extension.downcase)
      record.errors.add(attr_name, I18n.t("validators.file_type"))
    end
  end
end
