# These Rake tasks download IRS e-file schemas from S3.
# We avoid storing them in the repo because the IRS asked us nicely to
# try to limit distribution.
require 'zip'

namespace :efile do
  desc "Download and unpack IRS e-file schemas"

  FILENAME = "efile1040x_2020v5.1.zip"

  task download: :environment do |_task|
    download_path = Rails.root.join('vendor', 'irs', FILENAME)
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
      key: FILENAME,
    )
  end

  task unzip: :environment do |_task|
    download_path = Rails.root.join('vendor', 'irs', FILENAME)
    raise StandardError.new("Download #{FILENAME} from s3://vita-min-irs-e-file-schema-prod and place it in vendor/irs/") unless File.exists?(download_path)

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
end
