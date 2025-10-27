require 'zip'

namespace :setup do
  desc "Download and/or unpack some dependencies for vita-min"

  VENDOR_DIR = "vendor"

  def vendor_dir
    File.join(Rails.root, VENDOR_DIR)
  end

  # These Rake tasks download IRS e-file schemas from S3.
  # We avoid storing them in the repo because the IRS asked us nicely to
  # try to limit distribution.
  task download_efile_schemas: :environment do |_task|
    SchemaFileLoader.prepare_directories(vendor_dir)
    SchemaFileLoader.download_schemas_from_s3(vendor_dir)
  end

  task unzip_efile_schemas: :environment do |_task|
    SchemaFileLoader.unzip_schemas(vendor_dir)
    missing_files = SchemaFileLoader.get_missing_downloads(vendor_dir)
    if missing_files.present?
      message = <<~MESSAGE
        You need to manually download the following files from https://drive.google.com/drive/u/0/folders/1ssEXuz5WDrlr9Ng7Ukp6duSksNJtRATa
        #{missing_files.map { |(filename, download_folder)| "#{filename} to vendor/#{download_folder}" }.join("\n")}
      MESSAGE
      raise StandardError.new(message)
    end
  end

  task download_gyr_efiler: :environment do |_task|
    paths = [
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-classes-#{Efile::GyrEfilerService.current_version}.zip"),
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-config-#{Efile::GyrEfilerService.current_version}.zip")
    ]
    # If the file already exists, do not re-download.
    next if paths.all? { |p| File.exist?(p) }

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
