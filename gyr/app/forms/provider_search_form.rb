class ProviderSearchForm < Form
  attr_accessor :zip, :page
  validates :zip, zip_code: true
  validates :page, gyr_numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true

  def valid_zip_searched?
    zip.present? && errors.empty?
  end
end
