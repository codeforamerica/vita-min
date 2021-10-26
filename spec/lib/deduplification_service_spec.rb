require "rails_helper"

describe DeduplificationService do
  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:db_encryption_key).and_call_original
    allow(EnvironmentCredentials).to receive(:dig).with(:hash_key).and_return "secret"
  end

  describe '.hmac_hexdigest' do
    it 'uses the hash_key to create a hexdigest' do
      expect(described_class.hmac_hexdigest("123456789")).to eq "e9f1f91535398c73105b095ee2be45fa6a26fd4ee56f17b1410ce2145850df42"
    end
  end

  describe ".duplicates" do
    let(:instance) { create :bank_account }
    let(:query_double) { double }

    before do
      allow(BankAccount).to receive_message_chain(:where, :not).and_return query_double
      allow(query_double).to receive(:where).and_return query_double
    end

    context "when passed with one attr" do
      it "uses the single argument to create the where clause" do
        described_class.duplicates(instance, :hashed_routing_number)
        expect(query_double).to have_received(:where).with({ hashed_routing_number: instance.hashed_routing_number })
      end
    end

    context "when passed with an array of attributes" do
      it "uses the attributes to create the where clause" do
        described_class.duplicates(instance, :hashed_routing_number, :hashed_account_number)
        expect(query_double).to have_received(:where).with({ hashed_routing_number: instance.hashed_routing_number, hashed_account_number: instance.hashed_account_number })
      end
    end
  end
end