require 'zip'

namespace :setup do
  desc "Download and/or unpack some dependencies for vita-min"

  EFILE_SCHEMAS_FILENAME = "efile1040x_2020v5.1.zip"

  # These Rake tasks download IRS e-file schemas from S3.
  # We avoid storing them in the repo because the IRS asked us nicely to
  # try to limit distribution.
  task download_efile_schemas: :environment do |_task|
    download_path = Rails.root.join('vendor', 'irs', EFILE_SCHEMAS_FILENAME)
    # If the file already exists, do not re-download.
    next if File.exists?(download_path)

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
    Aws::S3::Client.new(region: 'us-east-1', credentials: credentials).get_object(
      response_target: download_path,
      bucket: "vita-min-irs-e-file-schema-prod",
      key: EFILE_SCHEMAS_FILENAME,
    )
  end

  task unzip_efile_schemas: :environment do |_task|
    download_path = Rails.root.join('vendor', 'irs', EFILE_SCHEMAS_FILENAME)
    raise StandardError.new("Download #{EFILE_SCHEMAS_FILENAME} and place it in vendor/irs/ from https://drive.google.com/drive/u/0/folders/1ssEXuz5WDrlr9Ng7Ukp6duSksNJtRATa") unless File.exists?(download_path)

    unpack_path = Rails.root.join('vendor', 'irs', 'unpacked')
    Zip::File.open_buffer(File.open(download_path, "rb")) do |zip_file|
      FileUtils.rm_rf(unpack_path)
      FileUtils.mkdir_p(unpack_path)
      Dir.chdir(unpack_path) do
        zip_file.each do |entry|
          raise StandardError.new("Unsafe filename; exiting") unless entry.name_safe?

          FileUtils.mkdir_p(File.dirname(entry.name))
          entry.extract
        end
      end
    end
  end

  task download_gyr_efiler: :environment do |_task|
    paths = [
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-classes-#{Efile::GyrEfilerService::CURRENT_VERSION}.zip"),
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-config-#{Efile::GyrEfilerService::CURRENT_VERSION}.zip")
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
