# These Rake tasks download IRS e-file schemas from S3.
# We avoid storing them in the repo because the IRS asked us nicely to
# try to limit distribution.
require 'zip'

namespace :efile do
  desc "Download and unpack IRS e-file schemas"

  FILENAME = "efile1040x_2020v5.1.zip"

  task download: :environment do |_task|
    output_path = Rails.root.join('tmp', FILENAME)
    # return if output_path.exists?
    # On Circle CI, get AWS credentials from environment.
    # In staging, demo, and prod environment, get credentials from Rails credentials.
    #
    # To test this locally, try: RAILS_ENV=staging rake efile:download
    credentials = if ENV["AWS_ACCESS_KEY_ID"].present?
                    Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
                  else
                    Aws::Credentials.new(
                      Rails.application.credentials.dig(:aws, :access_key_id),
                      Rails.application.credentials.dig(:aws, :secret_access_key),
                    )
                  end
    Aws::S3::Client.new(region: 'us-east-1', credentials: credentials).get_object(
      response_target: output_path,
      bucket: "vita-min-irs-e-file-schema-prod",
      key: FILENAME,
    )
  end

  task unzip: :environment do |_task|
    vendor_irs = Rails.root.join('vendor', 'irs')
    Zip::File.open_buffer(File.open(Rails.root.join('tmp', FILENAME), "rb")) do |zip_file|
      FileUtils.rm_rf(vendor_irs)
      FileUtils.mkdir_p(vendor_irs)
      Dir.chdir(vendor_irs) do
        zip_file.each do |entry|
          raise StandardError.new("Unsafe filename; exiting") unless entry.name_safe?

          FileUtils.mkdir_p(File.dirname(entry.name))
          entry.extract
        end
      end
    end
  end
end
