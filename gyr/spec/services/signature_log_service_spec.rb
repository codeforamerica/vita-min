require 'rails_helper'

describe SignatureLogService do
  let(:fake_s3) { instance_double(Aws::S3::Client) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return fake_s3
    allow(fake_s3).to receive(:put_object)
    allow(Time).to receive(:now).and_return(1234567890)
    allow(SecureRandom).to receive(:hex).with(20).and_return("randomHexStringAbc")
  end

  describe "#save_primary_signature_record" do
    let(:client_id) { 2 }
    let(:user_agent) { "GeckoFox" }
    let(:ip_address) { "127.0.0.1" }

    it "prefixes the client id onto the blob name" do
      record = <<~BLOB.chomp
        Type: Primary consent signature
        Name: Lola Lemon
        User agent (browser info): GeckoFox
        IP address: 127.0.0.1
        Time: 1234567890
      BLOB

      SignatureLogService.save_primary_signature_record(
        "Lola Lemon",
        client_id,
        user_agent,
        ip_address,
      )

      expect(fake_s3).to have_received(:put_object).with(
        key: "2/1234567890.randomHexStringAbc.txt",
        body: record,
        bucket: "vita-min-test-signatures"
      )
    end
  end

  describe "#save_spouse_signature_record" do
    let(:client_id) { 3 }
    let(:user_agent) { "KoolKrome" }
    let(:ip_address) { "127.0.0.2" }

    it "saves a record that the spouse signed, along with HTTP request info" do
      record = <<~BLOB.chomp
        Type: Spouse consent signature
        Name: Limey Lemon
        User agent (browser info): KoolKrome
        IP address: 127.0.0.2
        Time: 1234567890
      BLOB

      SignatureLogService.save_spouse_signature_record(
        "Limey Lemon",
        client_id,
        user_agent,
        ip_address,
      )

      expect(fake_s3).to have_received(:put_object).with(
        key: "3/1234567890.randomHexStringAbc.txt",
        body: record,
        bucket: "vita-min-test-signatures"
      )
    end
  end
end