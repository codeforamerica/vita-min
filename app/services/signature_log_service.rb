class SignatureLogService

  def self.save_signature_record(name, client_id, user_agent, ip_address)
    s3 = Aws::S3::Client.new(region: 'us-east-1', credentials: setAwsCredentails)
    s3.put_object(
      key: "blob_name",
      body: "record",
      bucket: "bucket"
    )
  end

  private

  def setAwsCredentails
    Aws::Credentials.new(
      Rails.application.credentials.dig(:access_key),
      Rails.application.credentials.dig(:secret_key)
    )
  end

end