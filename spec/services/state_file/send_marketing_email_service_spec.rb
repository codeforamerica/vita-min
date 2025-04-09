require 'rails_helper'

describe StateFile::SendMarketingEmailService do
  describe ".run" do
    let!(:az_intake_with_import) { create :state_file_az_intake, hashed_ssn: "123456789", df_data_imported_at: Date.new(MultiTenantService.new(:statefile).current_tax_year, 2, 1) }
    let!(:archived_az_intake_returned) { create :state_file_archived_intake, state_code: "az", hashed_ssn: "123456789" }

    let!(:archived_ny_intake) { create :state_file_archived_intake, state_code: "ny" }

    let!(:az_intake_without_import) { create :state_file_az_intake, hashed_ssn: "987654321", df_data_imported_at: nil }
    let!(:archived_az_intake_returned_no_import) { create :state_file_archived_intake, state_code: "az", hashed_ssn: "987654321" }

    let!(:archived_az_intake_not_returned) { create :state_file_archived_intake, state_code: "az" }

    it "sends a message to the archived AZ intakes and not the archived NY intakes" do
      expect {
        StateFile::SendMarketingEmailService.run
      }.to change(StateFileNotificationEmail, :count).by(2)

      expect(StateFileNotificationEmail.where(data_source: archived_az_intake_returned).count).to eq 0
      expect(StateFileNotificationEmail.where(data_source: archived_ny_intake).count).to eq 0
      expect(StateFileNotificationEmail.where(data_source: archived_az_intake_returned_no_import).count).to eq 1
      expect(StateFileNotificationEmail.where(data_source: archived_az_intake_not_returned).count).to eq 1
    end
  end
end
