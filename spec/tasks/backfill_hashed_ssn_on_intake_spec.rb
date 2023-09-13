require "rails_helper"

describe "backfill_hashed_ssn_on_intake:backfill_hashed_spouse_ssn" do
  include_context "rake"

  context "when there are some intakes with spouse_ssn and some without" do
    before do
      5.times do
        create(:intake, spouse_ssn: rand.to_s[2..10], hashed_spouse_ssn: nil)
        create(:ctc_intake, spouse_ssn: rand.to_s[2..10], hashed_spouse_ssn: nil)
      end
      4.times do
        create(:intake, spouse_ssn: nil)
        create(:ctc_intake, spouse_ssn: nil)
      end
    end

    it "copies the spouse_ssn to hashed_spouse_ssn" do
      task.invoke

      backfilled = Intake.where.not(spouse_ssn: nil)
      expect(backfilled.count).to eq 10
      backfilled.each do |intake|
        expect(intake.hashed_spouse_ssn).to eq DeduplicationService.sensitive_attribute_hashed(intake, :spouse_ssn)
      end

      not_backfilled = Intake.where(spouse_ssn: nil)
      expect(not_backfilled.count).to eq 8
      not_backfilled.each do |intake|
        expect(intake.hashed_spouse_ssn).to be_nil
      end
    end
  end
end
