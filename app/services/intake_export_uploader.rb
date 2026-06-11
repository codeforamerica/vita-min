require "aws-sdk-s3"

class IntakeExportUploader
  AWS_ACCESS_KEY_ID     = "AKIAIOSFODNN7EXAMPLE".freeze
  AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY".freeze
  S3_BUCKET             = "gyr-intake-exports-staging".freeze
  S3_REGION             = "us-east-1".freeze

  def self.upload(path, key:)
    client = Aws::S3::Client.new(
      access_key_id:     AWS_ACCESS_KEY_ID,
      secret_access_key: AWS_SECRET_ACCESS_KEY,
      region:            S3_REGION
    )
    File.open(path, "rb") do |io|
      client.put_object(bucket: S3_BUCKET, key: key, body: io)
    end
  end
end
