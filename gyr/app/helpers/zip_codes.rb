class ZipCodes
  def self.coordinates_for_zip_code(zip)
    self.zip_codes.dig(zip, :coordinates)
  end

  def self.details(zip)
    self.zip_codes.dig(zip)
  end

  def self.has_key?(zip)
    self.zip_codes.key?(zip)
  end

  private

  def self.zip_codes
    @zip_codes ||= IceNine.deep_freeze!(YAML.load_file("db/zip_codes.yml"))
  end
end
