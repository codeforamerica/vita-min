class ProviderSearchForm < Form
  validate :five_digit_zip

  attr_accessor :zip, :page

  ZIP_CODE_REGEX = /\A\d{5}\z/

  def five_digit_zip
    return true if (zip =~ ZIP_CODE_REGEX) && ZipCodes.has_key?(zip)
    errors.add(:zip, "Please enter a valid 5 digit zip code.")
    false
  end

  def valid_zip_searched?
    zip.present? && errors.empty?
  end
end