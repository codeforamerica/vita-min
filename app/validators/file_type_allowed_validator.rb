class FileTypeAllowedValidator < ActiveModel::EachValidator
  # The list of allowed types is security sensitive because it may allow files with script
  # capabilities to be uploaded leading to XSS attacks. Please be sure to know what you are
  # doing when modifying this list.

  FILE_TYPE_GROUPS = {
    browser_native_image: {
      extensions: [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".gif"],
      mime_type: ["image/jpeg", "image/png", "image/gif", "image/bmp", "image/tiff", "image/gif"]
    },
    other_image: {
      extensions: [".heic"],
      mime_type: ["image/heic"]
    },
    document: {
      extensions: [".txt", ".pdf"],
      mime_type: ["text/plain", "application/pdf"]
    },
  }

  def self.extensions(model)
    model::ACCEPTED_FILE_TYPES.map { |group| FILE_TYPE_GROUPS[group][:extensions] }.flatten
  end

  # TODO: remove these
  # VALID_FILE_EXTENSIONS = [".jpg", ".jpeg", ".pdf", ".png", ".heic", ".bmp", ".txt", ".tiff", ".gif"]
  # VALID_MIME_TYPES = ["image/jpeg", "image/png", "application/pdf", "image/heic", "image/bmp", "text/plain", "image/tiff", "image/gif"]

  def validate_each(record, attr_name, value)
    return if !value

    valid_extensions = record.class::ACCEPTED_FILE_TYPES.map { |group| FILE_TYPE_GROUPS[group][:extensions] }.flatten
    unless valid_extensions.include?(value.filename.extension_with_delimiter.downcase)
      record.errors.add(attr_name, I18n.t("validators.file_type", valid_types: valid_extensions.to_sentence))
    end
  end
end
