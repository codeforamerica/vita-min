# Expire S3 transient links quickly, nearly immediately
Rails.application.config.active_storage.service_urls_expire_in = 20.seconds
