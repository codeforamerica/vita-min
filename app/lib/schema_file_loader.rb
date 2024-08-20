class SchemaFileLoader

  BUCKET = "vita-min-irs-e-file-schema-prod".freeze
  REGION = "us-east-1".freeze
  EFILE_SCHEMAS_FILENAMES = (
    [
      ["efile1040x_2020v5.1.zip", "irs"],
      ["efile1040x_2021v5.2.zip", "irs"],
      ["efile1040x_2022v5.3.zip", "irs"],
      ["efile1040x_2023v5.0.zip", "irs"]
    ] +
      StateFile::StateInformationService.state_schema_file_names.map do |schema_file_name|
        [schema_file_name, "us_states"]
      end
  ).freeze

  class << self
    def load_file(*path)
      # First we check the vendor directory - if the file is there use it (Non heroku cases)
      file = File.join(Rails.root, "vendor", *path)
      return file if File.exist?(file)

      # Next we check the tmp directory in case we already downloaded the file
      file = File.join(Rails.root, "tmp", *path)
      download_and_unzip_schemas_from_s3(File.join(Rails.root, "tmp")) unless File.exist?(file)

      file
    end

    def download_and_unzip_schemas_from_s3(dest_dir)
      prepare_directories(dest_dir)
      download_schemas_from_s3(dest_dir)
      unzip_schemas(dest_dir)
    end

    def download_schemas_from_s3(dest_dir)
      s3_client = Aws::S3::Client.new(region: REGION, credentials: s3_credentials)
      get_missing_downloads(dest_dir).each do |download_path|
        s3_client.get_object(
          response_target: download_path,
          bucket: BUCKET,
          key: File.basename(download_path),
        )
      end
    end

    def s3_credentials
      # On Circle CI, get AWS credentials from environment.
      # In staging, demo, heroku, and prod environment, get credentials from Rails credentials.
      #
      # In development, download the file manually from S3. This allows us to avoid storing any AWS credentials in the development secrets.
      if ENV["AWS_ACCESS_KEY_ID"].present?
        return Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
      end

      Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key),
      )
    end

    def prepare_directories(dest_dir)
      download_folders = EFILE_SCHEMAS_FILENAMES.map { |n| n[1] }.to_set
      download_folders.each do |download_folder|
        unpack_path = File.join(dest_dir, download_folder, 'unpacked')
        FileUtils.rm_rf(unpack_path)
        FileUtils.mkdir_p(unpack_path)
      end
    end

    def get_missing_downloads(dest_dir)
      download_files = EFILE_SCHEMAS_FILENAMES.map do |(filename, download_folder)|
        File.join(dest_dir, download_folder, filename)
      end
      download_files.filter do |download_file|
        !File.exist?(download_file)
      end
    end

    def unzip_schemas(dest_dir)
      EFILE_SCHEMAS_FILENAMES.each do |(filename, download_folder)|
        download_path = File.join(dest_dir, download_folder, filename)
        next unless File.exist?(download_path)
        Zip::File.open_buffer(File.open(download_path, "rb")) do |zip_file|
          # A zip file like AZIndividual2022v1.1.zip will either contain files like AZIndividual2022v1.1/AZIndividual/etc
          # *or* just AZIndividual. Here we normalize by always trying to unzip in such a way that results in a unique
          # folder for every schema version
          path_parts = [dest_dir, download_folder, 'unpacked']
          zip_filename = File.basename(zip_file.name, '.zip')
          if download_folder == 'us_states' && !zip_file.first.name.start_with?(zip_filename)
            path_parts << zip_filename
          end
          unpack_path = File.join(*path_parts)
          FileUtils.mkdir_p(unpack_path)

          Dir.chdir(unpack_path) do
            zip_file.each do |entry|
              raise StandardError.new("Unsafe filename; exiting") unless entry.name_safe?

              FileUtils.mkdir_p(File.dirname(entry.name))

              # The block is used to decide whether to proceed with extraction
              # when we see the path already exists. By saying 'true' we proceed
              # with overwriting the extracted files.
              entry.extract { true }
            end
          end
        end
      end
    end
  end
end
