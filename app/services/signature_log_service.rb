class SignatureLogService
  def self.save_signature_record(name, client_id, user_agent, ip_address)
    record = "Name: #{name}\nUser agent (browser info): #{user_agent}\nIP address: #{ip_address}\nTime: #{Time.now}"
    blob_name = "#{client_id}/#{Time.now.to_i}.#{Base64.encode64(SecureRandom.random_bytes(16)).delete('/').chomp}.txt"

    s3 = Aws::S3::Client.new(region: 'us-east-1', credentials: setAwsCredentials)

    s3.put_object(
      key: blob_name,
      body: record,
      bucket: Rails.configuration.signature_log_bucket
    )
  end

  private

  def self.setAwsCredentials
    Aws::Credentials.new(
      Rails.application.credentials.dig(:access_key),
      Rails.application.credentials.dig(:secret_key)
    )
  end
end