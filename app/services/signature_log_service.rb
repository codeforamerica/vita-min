class SignatureLogService
  def self.save_signature_record(name, client_id, user_agent, ip_address)
    record = "Name: #{name}\nUser agent (browser info): #{user_agent}\nIP address: #{ip_address}\nTime: #{Time.now}"
    blob_name = "#{client_id}/#{Time.now.to_i}.#{Base64.encode64(SecureRandom.random_bytes(16)).delete('/').chomp}.txt"
    if Rails.application.config.signature_log_bucket == "stderr"
      STDERR.write("#{blob_name}=#{record}")
    else
      s3_client = Aws::S3::Client.new(region: 'us-east-1')

      s3_client.put_object(
        key: blob_name,
        body: record,
        bucket: Rails.application.config.signature_log_bucket
      )
    end
  end
end