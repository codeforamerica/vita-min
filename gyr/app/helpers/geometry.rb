class Geometry
  def self.geometry_factory
    @factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
  end

  def self.coords_to_point(lat:, lon:)
    geometry_factory.point(lon, lat)
  end
end