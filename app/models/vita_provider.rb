class VitaProvider < ApplicationRecord
  validates :irs_id, presence: true, uniqueness: true

  def set_coordinates(lat:, lon:)
    self.coordinates = geometry_factory.point(lon, lat)
  end

  private

  def geometry_factory
    @geometry_factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
  end
end