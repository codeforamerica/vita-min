# == Schema Information
#
# Table name: vita_providers
#
#  id               :bigint           not null, primary key
#  appointment_info :string
#  archived         :boolean          default(FALSE), not null
#  coordinates      :geography        point, 4326
#  dates            :string
#  details          :string
#  hours            :string
#  languages        :string
#  name             :string
#  created_at       :datetime
#  updated_at       :datetime
#  irs_id           :string           not null
#  last_scrape_id   :bigint
#
# Indexes
#
#  index_vita_providers_on_irs_id          (irs_id) UNIQUE
#  index_vita_providers_on_last_scrape_id  (last_scrape_id)
#
# Foreign Keys
#
#  fk_rails_...  (last_scrape_id => provider_scrapes.id)
#

class VitaProvider < ApplicationRecord
  belongs_to :last_scrape, class_name: "ProviderScrape", optional: true

  self.per_page = 5
  DISTANCE_LIMIT = 80467.2 # 50 miles to meters
  validates :irs_id, presence: true, uniqueness: true

  scope :unscraped_by, -> (scrape) { where.not(last_scrape: scrape).or( where(last_scrape: nil) ) }
  scope :listed, -> { where(archived: false) }

  def self.sort_by_distance_from_zipcode(zip, page_number = nil)
    coords = ZipCodes.coordinates_for_zip_code(zip)
    from_point = Geometry.coords_to_point(lon: coords[1], lat: coords[0])

    listed.page(page_number).select(Arel.sql("ST_Distance(coordinates, ST_GeomFromText('#{from_point.as_text}', 4326)) as cached_query_distance, *"))
      .where(Arel.sql("ST_DWithin(coordinates, ST_GeomFromText('#{from_point.as_text}', 4326), #{DISTANCE_LIMIT})"))
      .order(Arel.sql("cached_query_distance"))
  end

  def set_coordinates(lat:, lon:)
    self.coordinates = Geometry.coords_to_point(lat: lat, lon: lon)
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
      notes: lines.present? ? lines : [],
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
    PhoneParser.formatted_phone_number(phone_number)
  end

  def google_maps_url
    zoom_level = 16
    escaped_address = CGI.escape("#{street_address} #{unit} #{city_state_zip}").gsub(" ", "+")
    "https://www.google.com/maps/place/#{escaped_address}/@#{coordinates.lat},#{coordinates.lon},#{zoom_level}z/"
  end

  def same_as_irs_result?(provider_data)
    # does not check coordinates
    irs_id == provider_data[:irs_id] &&
      name == provider_data[:name] &&
      details == provider_data[:provider_details] &&
      dates == provider_data[:dates] &&
      hours == provider_data[:hours] &&
      languages == provider_data[:languages].join(",") &&
      appointment_info == provider_data[:appointment_info]
  end

  def update_with_irs_data(provider_data)
    set_coordinates(
      lat: provider_data[:lat_long].first,
      lon: provider_data[:lat_long].second
    )
    update(
      name: provider_data[:name],
      irs_id: provider_data[:irs_id],
      details: provider_data[:provider_details],
      dates: provider_data[:dates],
      hours: provider_data[:hours],
      languages: provider_data[:languages].join(","),
      appointment_info: provider_data[:appointment_info],
    )
  end

  def is_listed?
    archived == false
  end

  private

  def get_phone_number(lines)
    lines.length > 0 && lines[-1].match?(/(\d{3}-\d{3}-\d{4})/) ? lines.pop : nil
  end

  def get_unit_number(lines)
    unit_matchers = ["#", "unit", "building", "floor", "ste", "suite", "bldg", "p.o.", "courthouse", "room", "plaza", "school", "[0-9][0-9][0-9]+"]

    lines.length > 0 && unit_matchers.any? { |matcher| lines[0].match?(/#{matcher}/i) } ? lines.shift : nil
  end
end
