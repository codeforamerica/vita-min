require 'zip'

namespace :setup do
  desc "Download and/or unpack some dependencies for vita-min"

  EFILE_SCHEMAS_FILENAMES = [
    ["efile1040x_2020v5.1.zip", "irs"],
    ["efile1040x_2021v5.2.zip", "irs"],
    ["efile1040x_2022v5.3.zip", "irs"],
    ["efile1040x_2023v3.0.zip", "irs"],
    ["NYSIndividual2023V3.0.zip", "us_states"],
    ["AZIndividual2023v1.0.zip", "us_states"],
  ].freeze

  # These Rake tasks download IRS e-file schemas from S3.
  # We avoid storing them in the repo because the IRS asked us nicely to
  # try to limit distribution.
  task download_efile_schemas: :environment do |_task|
    EFILE_SCHEMAS_FILENAMES.each do |(filename, download_folder)|
      download_path = Rails.root.join('vendor', download_folder, filename)
      # If the file already exists, do not re-download.
      next if File.exist?(download_path)

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
        key: filename,
      )
    end
  end

  task unzip_efile_schemas: :environment do |_task|
    [Rails.root.join('vendor', 'irs', 'unpacked'), Rails.root.join('vendor', 'us_states', 'unpacked')].each do |unpack_path|
      FileUtils.rm_rf(unpack_path)
      FileUtils.mkdir_p(unpack_path)
    end

    missing_files = []

    EFILE_SCHEMAS_FILENAMES.each do |(filename, download_folder)|
      download_path = Rails.root.join('vendor', download_folder, filename)
      missing_files << [filename, download_folder] unless File.exist?(download_path)
      next if missing_files.present?

      Zip::File.open_buffer(File.open(download_path, "rb")) do |zip_file|
        # A zip file like AZIndividual2022v1.1.zip will either contain files like AZIndividual2022v1.1/AZIndividual/etc
        # *or* just AZIndividual. Here we normalize by always trying to unzip in such a way that results in a unique
        # folder for every unzip
        path_parts = ['vendor', download_folder, 'unpacked']
        zip_filename = File.basename(zip_file.name, '.zip')
        if download_folder == 'us_states' && !zip_file.first.name.start_with?(zip_filename)
          path_parts << zip_filename
        end
        unpack_path = Rails.root.join(*path_parts)
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

    if missing_files.present?
      message = <<~MESSAGE
        Download the following files from https://drive.google.com/drive/u/0/folders/1ssEXuz5WDrlr9Ng7Ukp6duSksNJtRATa
        #{missing_files.map { |(filename, download_folder)| "#{filename} to vendor/#{download_folder}" }.join("\n")}
      MESSAGE
      raise StandardError.new(message)
    end
  end

  task download_gyr_efiler: :environment do |_task|
    paths = [
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-classes-#{Efile::GyrEfilerService::CURRENT_VERSION}.zip"),
      Rails.root.join('vendor', 'gyr_efiler', "gyr-efiler-config-#{Efile::GyrEfilerService::CURRENT_VERSION}.zip")
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
