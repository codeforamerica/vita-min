class RefreshCachesJob < ApplicationJob
  # Each class/item in the MANIFEST needs to have a
  # public method named `refresh_cache`; from there, the
  # internal implementation is up to the maintainer of that class.
  MANIFEST = [
    AiScreenerMetricsService]

  def perform
    MANIFEST.map(&:refresh_cache)
  end

  def priority
    PRIORITY_LOW
  end
end
