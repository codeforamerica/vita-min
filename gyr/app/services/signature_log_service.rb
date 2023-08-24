class SignatureLogService
  def self.save_primary_signature_record(name, client_id, user_agent, ip_address)
    self.save_signature_record("Primary consent signature", name, client_id, user_agent, ip_address)
  end

  def self.save_spouse_signature_record(name, client_id, user_agent, ip_address)
    self.save_signature_record("Spouse consent signature", name, client_id, user_agent, ip_address)
  end

  private

  def self.save_signature_record(record_type, name, client_id, user_agent, ip_address)
    record = "Type: #{record_type}\nName: #{name}\nUser agent (browser info): #{user_agent}\nIP address: #{ip_address}\nTime: #{Time.now}"
    unique_filename = "#{client_id}/#{Time.now.to_i}.#{SecureRandom.hex(20)}.txt"

    s3 = Aws::S3::Client.new(region: 'us-east-1', credentials: Aws::Credentials.new(
      Rails.application.credentials.dig(:aws, :access_key_id),
      Rails.application.credentials.dig(:aws, :secret_access_key),
    ))

    s3.put_object(
      key: unique_filename,
      body: record,
      bucket: Rails.configuration.signature_log_bucket
    )
  end

end