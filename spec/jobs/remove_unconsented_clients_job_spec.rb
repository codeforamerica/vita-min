require "rails_helper"

describe RemoveUnconsentedClientsJob do
  describe "#perform" do
    context 'when there are barely started intakes' do
      # The id juggling is just because we want to resemble prod, where Archived::Intake2021 records have ids that are strictly smaller than ones in the Intake table
      let!(:archived_intake) { create(:archived_2021_gyr_intake, id: 11, source: 'elephant', client: build(:client, created_at: 349.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_ctc_intake) { create(:ctc_intake, id: 12, source: 'llama', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_gyr_intake) { create(:intake, id: 13, source: 'giraffe', referrer: 'https://example.com/', triage_filing_frequency: "unfilled", triage_filing_status: "single", triage_income_level: "unfilled", triage_vita_income_ineligible: "yes", client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_ctc_intake_with_message) { create(:ctc_intake, id: 14, source: 'marmoset', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_ctc_intake_with_docs) { create(:ctc_intake, id: 15, source: 'pelican', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:new_unconsented_ctc_intake) { create(:intake, id: 16, source: 'porcupine', client: build(:client, created_at: 1.hour.ago, consented_to_service_at: nil)) }
      let!(:old_consented_gyr_intake) { create(:intake, id: 17, source: 'fox', primary_consented_to_service: "yes", client: build(:client, created_at: 3.days.ago, consented_to_service_at: DateTime.now)) }

      let!(:old_unconsented_ctc_intake_with_message_message) { create(:incoming_text_message, client: old_unconsented_ctc_intake_with_message.client) }
      let!(:old_unconsented_ctc_intake_with_docs_doc) { create(:document, intake: old_unconsented_ctc_intake_with_docs, client: old_unconsented_ctc_intake_with_docs.client) }

      it 'deletes clients where primary has not consented were created more than 2 days ago' do
        SearchIndexer.refresh_filterable_properties(Client.all)

        expect(Intake.all.map(&:id)).to match_array([
                                                      old_unconsented_gyr_intake,
                                                      old_unconsented_ctc_intake,
                                                      old_unconsented_ctc_intake_with_message,
                                                      old_unconsented_ctc_intake_with_docs,
                                                      new_unconsented_ctc_intake,
                                                      old_consented_gyr_intake
                                                    ].map(&:id))

        RemoveUnconsentedClientsJob.new.perform

        expect(Intake.all.map(&:id)).to match_array([new_unconsented_ctc_intake, old_consented_gyr_intake, old_unconsented_ctc_intake_with_message, old_unconsented_ctc_intake_with_docs].map(&:id))

        expect(AbandonedPreConsentIntake.pluck('id')).to match_array([old_unconsented_gyr_intake, old_unconsented_ctc_intake].map(&:id))
        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_ctc_intake.id).attributes).to match hash_including(
                                                                                                           'client_id' => old_unconsented_ctc_intake.client_id,
                                                                                                           'intake_type' => 'Intake::CtcIntake',
                                                                                                           'source' => 'llama'
                                                                                                         )

        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_gyr_intake.id).attributes).to match hash_including(
                                                                                                        'client_id' => old_unconsented_gyr_intake.client_id,
                                                                                                        'visitor_id' => old_unconsented_gyr_intake.visitor_id,
                                                                                                        'referrer' => old_unconsented_gyr_intake.referrer,
                                                                                                        'triage_filing_frequency' => old_unconsented_gyr_intake.triage_filing_frequency,
                                                                                                        'triage_filing_status' => old_unconsented_gyr_intake.triage_filing_status,
                                                                                                        'triage_income_level' => old_unconsented_gyr_intake.triage_income_level,
                                                                                                        'triage_vita_income_ineligible' => old_unconsented_gyr_intake.triage_vita_income_ineligible,
                                                                                                        'intake_type' => 'Intake::GyrIntake',
                                                                                                        'source' => 'giraffe'
                                                                                                      )

        # Oldschool archived clients/intakes are not deleted at this time
        expect(archived_intake.reload).to be
      end
    end
  end
end