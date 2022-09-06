require 'rails_helper'

describe BulkAction::MessageCsvImportJob do
  let(:user) { create :admin_user, name: "Admin the First" }
  let!(:email_and_phone_client) { create :client_with_intake_and_return, tax_return_state: "prep_info_requested" }
  let!(:email_client) { create :client_with_intake_and_return, tax_return_state: "intake_reviewing" }
  let!(:archived_2021_email_client) { create(:client, tax_returns: [build(:tax_return, year: 2018)], intake: nil) }
  let!(:archived_2021_email_intake) { create(:archived_2021_gyr_intake, client: archived_2021_email_client, email_address: "someone_archived@example.com", email_notification_opt_in: "yes", locale: 'es') }

  before do
    login_as user
    email_client.intake.update(preferred_name: "Nombre", locale: "es", email_notification_opt_in: "yes", email_address: "someone@example.com")
    email_and_phone_client.intake.update(preferred_name: "Name", locale: "es", sms_notification_opt_in: "yes", sms_phone_number: "+15005550006", email_notification_opt_in: "yes", email_address: "someone_else@example.com")
  end

  let(:optional_bom) { '' }

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-client-message-test-#{SecureRandom.hex}.csv")
    File.write(@filename, <<~CSV)
      #{optional_bom}client_id
      #{email_and_phone_client.id}
      #{email_client.id}
      #{archived_2021_email_client.id}
    CSV
    example.run
    File.unlink(@filename)
  end

  describe '#perform_now' do
    let(:bulk_message_csv) { BulkMessageCsv.create(upload: { filename: 'really_good_csv.csv', io: File.open(@filename) }, user: user) }

    it "creates a tax return selection for the appropriate client ids" do
      described_class.perform_now(bulk_message_csv)
      expect(TaxReturnSelection.last.clients).to match_array([email_and_phone_client, email_client, archived_2021_email_client])
    end

    context "when the file contains a unicode byte order mark (BOM)" do
      let(:optional_bom) { "\xEF\xBB\xBF" }

      it "creates the tax return selection as normal" do
        described_class.perform_now(bulk_message_csv)
        expect(TaxReturnSelection.last.clients).to match_array([email_and_phone_client, email_client, archived_2021_email_client])
      end
    end
  end
end
