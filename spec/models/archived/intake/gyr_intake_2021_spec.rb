require "rails_helper"

describe Archived::Intake::GyrIntake2021 do
  describe ".completed_intakes" do
    let!(:intake_with_incomplete_tax_return_status) { create :archived_2021_gyr_intake, client: create(:client, intake: nil, tax_returns: [create(:gyr_tax_return, :intake_before_consent)]) }
    let!(:intake_with_complete_tax_return_status) { create :archived_2021_gyr_intake, client: create(:client, intake: nil, tax_returns: [create(:gyr_tax_return, :file_efiled)]) }

    it "returns intakes with INCLUDED_IN_PREVIOUS_YEAR_COMPLETED_INTAKES tax return states" do
      expect(described_class.completed_intakes).to match_array  [intake_with_complete_tax_return_status]
    end
  end
end
