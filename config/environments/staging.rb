require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging
end
