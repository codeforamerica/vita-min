require 'rails_helper'

describe SignatureLogService do
  let(:fake_s3) { double('s3') }

  before do
    allow(fake_s3).to receive(:put_object)

    SignatureLogService.instance.instance_variable_set(:@s3, fake_s3).with(region: 'us-east-1')
  end

  after do
    SignatureLogService.instance.remove_instance_variable(:@s3)
  end

  describe "#save_signature_record" do
    it "prefixes the client id onto the blob name" do
      SignatureLogService.save_signature_record(name, client_id, user_agent, ip_address)
      expect(fake_s3).to have_received(:put_object).once.with('')
    end
  end
end