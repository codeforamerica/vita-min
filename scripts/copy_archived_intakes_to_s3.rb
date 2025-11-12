#!/usr/bin/env ruby

require_relative '../config/environment'

class CopyArchivedIntakesToS3 < Thor
  default_task :dump

  desc "dump", "Dumps, then copies the appropriate table to s3"
  def dump
    say "Dumping and compressing archived intakes...", :green
    pg_dump(db_connection_string, "state_file_archived_intakes.sql")
  end

  no_tasks do
    def pg_dump(connection_string, file_name)
      output, = Open3.capture3(
        'pg_dump',
        connection_string,
        '-t',
        'state_file_archived_intakes',
        '--data-only',
        '--no-owner',
        '--no-privileges',
      )

      write_output(output, file_name)

      say "Wrote to '#{tagged_path(file_name)}'", :green
    end

    def db_connection_string
      config_hash = ActiveRecord::Base.connection_db_config
        .as_json
        .with_indifferent_access[:configuration_hash]

      case config_hash
      in host:, port:, username:, password:, database:
        "postgres://#{username}:#{password}@#{host}:#{port}/#{database}"
      in host:, port:, database:
        "postgres://#{host}:#{port}/#{database}"
      end
    end

    def write_output(output, file_name)
      if Rails.env.development? && ENV["AWS_ACCESS_KEY_ID"].blank?
        write_to_file(output, file_name)
      else
        write_to_s3(output, file_name)
      end
    end

    def write_to_file(output, file_name)
      File.open("tmp/#{tagged_path(file_name)}", 'w', binmode: true) do |file_obj| 
        file_obj.write(Zlib.gzip(output))
        next file_obj
      end
    end

    def write_to_s3(output, file_name)
      s3_client.put_object(
        bucket: destination_bucket,
        key: tagged_path(file_name),
        body: Zlib.gzip(output)
      )
    end

    def destination_bucket
      if Rails.env.production?
        "vita-min-archived-intakes-submission-pdfs"
      else
        "vita-min-demo-archived-intakes-submission-pdfs"
      end
    end


    def tagged_path(file_name)
      current_time = Time.current
      timestamp_string = current_time.strftime("%Y%m%d-%H%M%S")

      "#{file_name}-#{timestamp_string}.gz"
    end

    def s3_client
      Aws::S3::Client.new(
        region: "us-east-1",
        credentials: s3_credentials
      )
    end

    def s3_credentials
      if ENV["AWS_ACCESS_KEY_ID"].present? # is this for local?
        Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV.fetch("AWS_SECRET_ACCESS_KEY", nil))
      else
        Aws::Credentials.new(
          Rails.application.credentials.dig(:aws, :access_key_id),
          Rails.application.credentials.dig(:aws, :secret_access_key)
        )
      end
    end
  end
end

CopyArchivedIntakesToS3.start
