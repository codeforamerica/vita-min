require 'rails_helper'

describe SignatureLogService do
  let(:fake_s3) { instance_double(Aws::S3::Client) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return fake_s3
    Aws.config.update(stub_responses: true)
    allow(fake_s3).to receive(:put_object)
  end

  describe "#save_signature_record" do
    let(:client) { create :client, intake: ( create :intake, primary_first_name: "Lola", primary_last_name: "Lemon" ) }
    let(:user_agent) { "Mozilla/5.0 (platform; rv:geckoversion) Gecko/geckotrail Firefox/firefoxversion" }
    let(:ip_address) { "127.0.0.1" }

    it "prefixes the client id onto the blob name" do
      blob_name_partial = "#{client.id}/#{Time.now.to_i}."
      record = "Name: #{client.intake.primary_first_name} #{client.intake.primary_last_name}\nUser agent (browser info): #{user_agent}\nIP address: #{ip_address}\nTime: #{Time.now}"

      SignatureLogService.save_signature_record("#{client.intake.primary_first_name} #{client.intake.primary_last_name}", client.id, user_agent, ip_address)

      expect(fake_s3).to have_received(:put_object).with(
        key: include(blob_name_partial),
        body: record,
        bucket: "vita-min-development"
      )
    end
  end
end