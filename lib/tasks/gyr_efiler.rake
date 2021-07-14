# These Rake tasks download our gyr efiler
require 'zip'

namespace :gyr_efiler do
  desc "Download and unpack GYR Efiler release"

  task download: :environment do |_task|
    paths = [
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-classes-#{GyrEfilerService::CURRENT_VERSION}.zip"),
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-config-#{GyrEfilerService::CURRENT_VERSION}.zip")
    ]
    # If the file already exists, do not re-download.
    next if paths.all? { |p| File.exists?(p) }

    # On Circle CI, get AWS credentials from environment.
    # In staging, demo, and prod environment, get credentials from Rails credentials.
    #
    # In development, download the file manually from S3. This allows us to avoid storing any AWS credentials in the development secrets.
    credentials = if ENV["AWS_ACCESS_KEY_ID"].present?
                    Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
                  else
                    Aws::Credentials.new(
                      Rails.application.credentials.dig(:aws, :access_key_id),
                      Rails.application.credentials.dig(:aws, :secret_access_key),
                    )
                  end
    paths.each do |path|
      Aws::S3::Client.new(region: 'us-east-1', credentials: credentials).get_object(
        response_target: path,
        bucket: "gyr-efiler-releases",
        key: File.basename(path),
      )
    end
  end
end
