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
  let(:csv_content) do
    <<~CSV
      #{optional_bom}client_id
      #{email_and_phone_client.id}
      #{email_client.id}
      #{archived_2021_email_client.id}
    CSV
  end

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-client-message-test-#{SecureRandom.hex}.csv")
    File.write(@filename, csv_content)
    example.run
    File.unlink(@filename)
  end

  describe '#perform_now' do
    let(:bulk_message_csv) { BulkMessageCsv.create(upload: { filename: 'really_good_csv.csv', io: File.open(@filename) }, user: user) }

    it "creates a tax return selection for the appropriate client ids" do
      expect do
        described_class.perform_now(bulk_message_csv)
      end.to change { bulk_message_csv.reload.status }.to('ready')

      expect(TaxReturnSelection.last.clients).to match_array([email_and_phone_client, email_client, archived_2021_email_client])
    end

    context "when the file contains a unicode byte order mark (BOM)" do
      let(:optional_bom) { "\xEF\xBB\xBF" }

      it "creates the tax return selection as normal" do
        described_class.perform_now(bulk_message_csv)
        expect(TaxReturnSelection.last.clients).to match_array([email_and_phone_client, email_client, archived_2021_email_client])
      end
    end

    context "when the file does not contain any client ids with tax returns" do
      let!(:no_tax_returns_client_id) { create(:client).id }
      let(:nonexistent_client_id) { -1000 }

      let(:csv_content) do
        <<~CSV
          client_id
          #{no_tax_returns_client_id}
          #{nonexistent_client_id}
        CSV
      end

      it "sets the status to 'empty'" do
        expect do
          expect do
            described_class.perform_now(bulk_message_csv)
          end.not_to change(TaxReturnSelection, :count)
        end.to change { bulk_message_csv.reload.status }.to('empty')
      end
    end

    context "when the import fails for an unexpected reason" do
      before do
        allow(TaxReturn).to receive(:find_by_sql).and_raise(ArgumentError)
      end

      it "sets the status to 'failed' and still raises the error" do
        expect do
          described_class.perform_now(bulk_message_csv)
        end.to change { bulk_message_csv.reload.status }.to('failed').and(
          raise_error(ArgumentError)
        )
      end
    end
  end
end
