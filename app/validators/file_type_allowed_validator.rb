class FileTypeAllowedValidator < ActiveModel::EachValidator
  # The list of allowed types is security sensitive because it may allow files with script
  # capabilities to be uploaded leading to XSS attacks. Please be sure to know what you are
  # doing when modifying this list.

  FILE_TYPE_GROUPS = {
    browser_native_image: {
      extensions: [".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".gif"],
      mime_type: ["image/jpeg", "image/png", "image/bmp", "image/tiff", "image/gif"]
    },
    other_image: {
      extensions: [".heic"],
      mime_type: ["image/heic"]
    },
    document: {
      extensions: [".txt", ".pdf"],
      mime_type: ["text/plain", "application/pdf", "text/plain;charset=UTF-8"]
    },
  }

  def self.extensions(model)
    model::ACCEPTED_FILE_TYPES.map { |group| FILE_TYPE_GROUPS[group][:extensions] }.flatten
  end

  def self.mime_types(model)
    model::ACCEPTED_FILE_TYPES.map { |group| FILE_TYPE_GROUPS[group][:mime_type] }.flatten
  end

  def validate_each(record, attr_name, value)
    return unless value

    unless self.class.mime_types(record.class).include?(value.content_type)
      record.errors.add(attr_name, I18n.t("validators.file_type", valid_types: self.class.extensions(record.class).to_sentence))
    end
  end
end
