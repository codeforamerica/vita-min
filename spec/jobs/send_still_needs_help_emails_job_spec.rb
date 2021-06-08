require "rails_helper"

RSpec.describe SendStillNeedsHelpEmailsJob, type: :job do
  describe '#perform' do
    before do
      allow(ClientMessagingService).to receive(:contact_methods).and_return({ email: "example@example.com" })
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    let!(:inapplicable_client) { create(:client, vita_partner: create(:organization, name: "Definitely Not UU")) }
    let!(:some_inapplicable_tr) { create(:tax_return, client: inapplicable_client) }
    let!(:another_inapplicable_tr) { create(:tax_return, client: inapplicable_client, status: "intake_ready", year: 2018) }

    context 'when there are clients with UU as their vita partner' do
      let!(:urban_upbound) { create(:organization, name: "Urban Upbound") }
      let!(:uu_client) { create(:client, intake: create(:intake), vita_partner: urban_upbound) }
      let!(:another_uu_client) { create(:client, intake: create(:intake), vita_partner: urban_upbound) }

      context 'and they have tax returns in Ready to File and Not Ready' do
        let!(:ready_tr) { create(:tax_return, client: uu_client, status: "intake_ready") }

        let!(:another_ready_tr) { create(:tax_return, client: another_uu_client, status: "intake_ready") }
        let!(:not_ready_tr) { create(:tax_return, client: another_uu_client, status: "intake_in_progress", year: 2018) }

        it 'updates their triggered_still_needs_help_at and tax return statuses' do
          described_class.perform_now

          expect(Client.where.not(triggered_still_needs_help_at: nil)).to include(uu_client, another_uu_client)
          expect(Client.where(triggered_still_needs_help_at: nil)).to include(inapplicable_client)

          expect(TaxReturn.where(status: "file_not_filing")).to include(ready_tr, another_ready_tr, not_ready_tr)
          expect(TaxReturn.where.not(status: "file_not_filing")).to include(some_inapplicable_tr, another_inapplicable_tr)
        end

        it 'sends them an email' do
          described_class.perform_now

          expect(ClientMessagingService).to have_received(:send_system_email).twice
          expect(ClientMessagingService).not_to have_received(:send_system_text_message)
        end

        context 'and they are opted-in to text messaging' do
          before do
            allow(ClientMessagingService).to receive(:contact_methods).and_return({ sms_phone_number: "+14155551212", email: "example@example.com" })
          end

          it 'sends them a text message' do
            described_class.perform_now

            expect(ClientMessagingService).to have_received(:send_system_email).twice
            expect(ClientMessagingService).to have_received(:send_system_text_message).twice
          end
        end

        context 'and they have some tax returns in other statuses' do
          let!(:info_requested_tr) { create(:tax_return, client: another_uu_client, status: "review_info_requested", year: 2017) }

          it 'does not include them and their tax returns in the updates' do
            described_class.perform_now

            expect(Client.where(triggered_still_needs_help_at: nil)).to include(another_uu_client)
            expect(TaxReturn.where.not(status: "file_not_filing")).to include(another_ready_tr, not_ready_tr, info_requested_tr)
          end
        end

        context 'and they have tax returns in Not Filing' do
          let!(:not_filing_tr) { create(:tax_return, client: another_uu_client, status: "file_not_filing", year: 2017) }

          it 'does include them and their tax returns in the updates' do
            described_class.perform_now

            expect(Client.where.not(triggered_still_needs_help_at: nil)).to include another_uu_client
            expect(TaxReturn.where(status: "file_not_filing")).to include(another_ready_tr, not_ready_tr, not_filing_tr)
          end
        end
      end

      context 'and they have tax returns in only Not Filing' do
        let!(:not_filing_client) { create(:client, intake: create(:intake), vita_partner: urban_upbound) }
        let!(:not_filing_tr) { create(:tax_return, client: not_filing_client, status: "file_not_filing") }

        it 'does not include them in the updates' do
          described_class.perform_now

          expect(Client.where(triggered_still_needs_help_at: nil)).to include not_filing_client
        end
      end

      context 'when there are clients with UU as their vita partners parent org' do
        let!(:child_client) { create(:client, intake: create(:intake), vita_partner: create(:site, parent_organization: urban_upbound)) }
        let!(:child_tr) { create(:tax_return, client: child_client, status: "intake_ready") }

        it 'does include them and their tax returns in the updates' do
          described_class.perform_now

          expect(Client.where.not(triggered_still_needs_help_at: nil)).to include child_client
          expect(TaxReturn.where(status: "file_not_filing")).to include(child_tr)
        end
      end
    end
  end
end