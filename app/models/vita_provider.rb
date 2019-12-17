class VitaProvider < ApplicationRecord
  self.per_page = 5
  DISTANCE_LIMIT = 80467.2 # 50 miles to meters
  MILES_PER_METER = 0.000621371
  validates :irs_id, presence: true, uniqueness: true

  def self.geometry_factory
    RGeo::Geographic.spherical_factory(srid: 4326)
  end

  def self.geom_point_from_zip(zip)
    coords = ZipCodes.coordinates_for_zip_code(zip)
    geometry_factory.point(coords[1], coords[0])
  end

  def self.sort_by_distance_from_zipcode(zip, page_number = nil)
    from_point = geom_point_from_zip(zip)

    page(page_number).select(Arel.sql("ST_Distance(coordinates, ST_GeomFromText('#{from_point.as_text}', 4326)) as distance, *"))
      .where(Arel.sql("ST_DWithin(coordinates, ST_GeomFromText('#{from_point.as_text}', 4326), #{DISTANCE_LIMIT})"))
      .order(Arel.sql("distance"))
  end

  def set_coordinates(lat:, lon:)
    self.coordinates = self.class.geometry_factory.point(lon, lat)
  end

  def distance_from_zip(zip)
    zip_centroid = self.class.geom_point_from_zip(zip)
    (coordinates.distance(zip_centroid) * MILES_PER_METER).round(1)
  end

  def cached_search_distance_rounded_by_5_mi
    five_miles_in_meters = 8046.72
    (distance / five_miles_in_meters).ceil * 5
  end

  def parse_details
    return {} if details.blank?
    lines = details.split("\n")
    {
      street_address: lines.shift,
      service_type: lines.pop,
      phone_number: get_phone_number(lines),
      city_state_zip: lines.pop,
      unit: get_unit_number(lines),
      notes: lines.present? ? lines.join("\n") : nil,
    }
  end

  def street_address
    parse_details[:street_address]
  end

  def city_state_zip
    parse_details[:city_state_zip]
  end

  def unit
    parse_details[:unit]
  end

  def notes
    parse_details[:notes]
  end

  def service_type
    parse_details[:service_type]
  end

  def phone_number
    parse_details[:phone_number]
  end

  def formatted_phone_number
    phone_data.local_number
  end

  def sanitized_phone_number
    phone_data.sanitized
  end

  def google_maps_url
    zoom_level = 16
    escaped_address = CGI.escape("#{street_address} #{unit} #{city_state_zip}").gsub(" ", "+")
    "https://www.google.com/maps/place/#{escaped_address}/@#{coordinates.lat},#{coordinates.lon},#{zoom_level}z/"
  end

  private

  def phone_data
    Phonelib.parse("1#{phone_number}")
  end

  def get_phone_number(lines)
    lines.length > 0 && lines[-1].match?(/(\d{3}-\d{3}-\d{4})/) ? lines.pop : nil
  end

  def get_unit_number(lines)
    unit_prefixes = ["#", "unit", "Unit", "building", "Building", "floor", "Ste", "Suite", "[0-9]"]

    lines.length > 0 && unit_prefixes.any? { |prefix| lines[0].match?(/^#{prefix}/) } ? lines.shift : nil
  end
end