require "rails_helper"
require_relative "../../../db/data/20230915164214_backfill_hashed_spouse_ssn"

describe "BackfillHashedSpouseSsn" do
  let!(:intake_with_spouse) { create :intake, spouse_ssn: "123456789", hashed_spouse_ssn: nil }
  let!(:intake_with_spouse_and_hash) { create :intake, spouse_ssn: "123456789", hashed_spouse_ssn: "1234567890847635" }
  let!(:intake_without_spouse) { create :intake, spouse_ssn: nil }

  context "with spouse_ssn and without hashed_spouse_ssn" do
    it "backfills hashed_spouse_ssn" do
      BackfillHashedSpouseSsn.new.up

      intake_with_spouse.reload
      expect(intake_with_spouse.hashed_spouse_ssn).not_to be_nil
    end
  end

  context "with spouse_ssn and with hashed_spouse_ssn" do
    it "does not change" do
      expect do
        BackfillHashedSpouseSsn.new.up
      end.not_to change { intake_with_spouse_and_hash.reload }
    end
  end

  context "without spouse_ssn" do
    it "remains nil" do
      expect do
        BackfillHashedSpouseSsn.new.up
      end.not_to change { intake_without_spouse.reload }

      expect(intake_without_spouse.hashed_spouse_ssn).to be_nil
    end
  end

end