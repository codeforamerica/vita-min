require "rails_helper"

describe "backfill:intakes" do
  include_context "rake"
  let(:task_name) { "backfill:intakes" }
  let(:task_path) { "lib/tasks/backfill_encrypted_intake_data" }

  around do |example|
    capture_output { example.run }
  end

  context "with a CTC Intake" do
    let!(:intake) {
      create :ctc_intake,
             attr_encrypted_primary_ssn: "123456789",
             primary_ssn: nil,
             attr_encrypted_spouse_ssn: "123456781",
             spouse_ssn: nil,
             attr_encrypted_bank_account_number: "123456789",
             bank_account_number: nil,
             attr_encrypted_bank_routing_number: "124444444",
             bank_routing_number: nil,
             attr_encrypted_bank_name: "Bank of Two Melons",
             bank_name: nil,
             attr_encrypted_spouse_ip_pin: nil,
             spouse_ip_pin: nil,
             attr_encrypted_primary_ip_pin: "123456",
             primary_ip_pin: nil,
             attr_encrypted_primary_signature_pin: "12346",
             primary_signature_pin: nil,
             attr_encrypted_spouse_signature_pin: "12345",
             spouse_signature_pin: nil
    }

    it "backfills all of the non-nil values and doesn't fail" do
      task.invoke
      intake.reload
      expect(intake.read_attribute(:primary_ssn)).to eq "123456789"
      expect(intake.read_attribute(:spouse_ssn)).to eq "123456781"
      expect(intake.read_attribute(:bank_account_number)).to eq "123456789"
      expect(intake.read_attribute(:bank_routing_number)).to eq "124444444"
      expect(intake.read_attribute(:bank_name)).to eq "Bank of Two Melons"
      expect(intake.read_attribute(:spouse_signature_pin)).to eq "12345"
      expect(intake.read_attribute(:primary_signature_pin)).to eq "12346"
      expect(intake.read_attribute(:primary_ip_pin)).to eq "123456"
    end
  end

  context "with a GYR Intake" do
    let!(:intake) {
      create :intake,
             attr_encrypted_primary_ssn: "123456789",
             primary_ssn: nil,
             attr_encrypted_spouse_ssn: "123456781",
             spouse_ssn: nil,
             attr_encrypted_bank_account_number: "123456789",
             bank_account_number: nil,
             attr_encrypted_bank_routing_number: "124444444",
             bank_routing_number: nil,
             attr_encrypted_bank_name: "Bank of Two Melons",
             bank_name: nil,
             attr_encrypted_spouse_ip_pin: nil,
             spouse_ip_pin: nil,
             attr_encrypted_primary_ip_pin: nil,
             primary_ip_pin: nil,
             attr_encrypted_primary_signature_pin: nil,
             primary_signature_pin: nil,
             attr_encrypted_spouse_signature_pin: nil,
             spouse_signature_pin: nil
    }

    it "updates all of the fields that aren't nil and doesnt fail" do
      task.invoke
      intake.reload
      expect(intake.read_attribute(:primary_ssn)).to eq "123456789"
      expect(intake.read_attribute(:spouse_ssn)).to eq "123456781"
      expect(intake.read_attribute(:bank_account_number)).to eq "123456789"
      expect(intake.read_attribute(:bank_routing_number)).to eq "124444444"
      expect(intake.read_attribute(:bank_name)).to eq "Bank of Two Melons"
      expect(intake.read_attribute(:spouse_signature_pin)).to eq nil
      expect(intake.read_attribute(:primary_signature_pin)).to eq nil
      expect(intake.read_attribute(:primary_ip_pin)).to eq nil
      expect(intake.read_attribute(:spouse_ip_pin)).to eq nil
    end
  end
end