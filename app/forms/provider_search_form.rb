class ProviderSearchForm < Form
  attr_accessor :zip, :page
  validates :zip, zip_code: true

  def valid_zip_searched?
    zip.present? && errors.empty?
  end
end