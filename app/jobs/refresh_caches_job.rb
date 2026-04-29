class RefreshCachesJob < ApplicationJob
  # Each class/item in the MANIFEST needs to have a
  # public method named `refresh_cache`; from there, the
  # internal impl. is up to the maintainer of that class.
  #
  # Suggested crontab entry:
  # 2 2 * * * bundle exec rake refresh_caches:perform

  MANIFEST = [
    AiScreenerMetricsService
  ]

  def perform
    MANIFEST.map(&:refresh_cache)
  end
end
