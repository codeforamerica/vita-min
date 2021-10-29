require "rails_helper"

describe DeduplificationService do
  before do
    allow(OpenSSL::HMAC).to receive(:hexdigest)
  end

  describe '.sensitive_attribute_hashed' do
    let(:bank_account) { build :bank_account, routing_number: "123456789" }
    context "without key param passed" do
      it 'uses the credentials hash_key to create a hexdigest' do
        described_class.sensitive_attribute_hashed(bank_account, :routing_number)
        expect(OpenSSL::HMAC).to have_received(:hexdigest).with("SHA256", "secret", "routing_number|123456789")
      end
    end

    context "with an explicit key param passed" do
      it 'uses the passed key as the key' do
        described_class.sensitive_attribute_hashed(bank_account, :routing_number, "shh")
        expect(OpenSSL::HMAC).to have_received(:hexdigest).with("SHA256", "shh", "routing_number|123456789")
      end
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

      context "when an old key is present" do
        before do
          allow(EnvironmentCredentials).to receive(:dig).with(:db_encryption_key).and_call_original
          allow(EnvironmentCredentials).to receive(:dig).with(:duplicate_hashing_key).and_call_original
          allow(EnvironmentCredentials).to receive(:dig).with(:previous_duplicate_hashing_key).and_return "another_secret"

          allow(described_class).to receive(:sensitive_attribute_hashed).and_return "new_hash"
          allow(described_class).to receive(:sensitive_attribute_hashed).with(instance, "routing_number", "another_secret").and_return "old_hash"
        end

        it "looks for the old and new hash in the db for matches on either" do
          described_class.duplicates(instance, :hashed_routing_number)
          expect(query_double).to have_received(:where).with({ hashed_routing_number: ["new_hash", "old_hash"] })
        end
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