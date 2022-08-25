require "rails_helper"

describe "backfill_hashed_primary_ssn_on_archived_intakes_2021:backfill" do
  include_context "rake"

  context "when there are some archived intakes with primary_ssn and some without" do
    before do
      5.times do
        create(:archived_2021_gyr_intake, primary_ssn: rand.to_s[2..10], hashed_primary_ssn: nil)
        create(:archived_2021_ctc_intake, primary_ssn: rand.to_s[2..10], hashed_primary_ssn: nil)
      end
      4.times do
        create(:archived_2021_gyr_intake, primary_ssn: nil)
        create(:archived_2021_ctc_intake, primary_ssn: nil)
      end
    end

    it "copies the primary_ssn to hashed_primary_ssn" do
      task.invoke

      backfilled = Archived::Intake2021.where.not(primary_ssn: nil)
      expect(backfilled.count).to eq 10
      backfilled.each do |intake|
        expect(intake.hashed_primary_ssn).to eq DeduplificationService.sensitive_attribute_hashed(intake, :primary_ssn)
      end

      not_backfilled = Archived::Intake2021.where(primary_ssn: nil)
      expect(not_backfilled.count).to eq 8
      not_backfilled.each do |intake|
        expect(intake.hashed_primary_ssn).to be_nil
      end
    end
  end
end
