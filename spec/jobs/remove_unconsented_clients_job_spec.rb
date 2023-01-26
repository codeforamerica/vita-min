require "rails_helper"

describe RemoveUnconsentedClientsJob do
  describe "#perform" do
    context 'when there are barely started intakes' do
      let!(:archived_intake) { create(:archived_2021_gyr_intake, id: 1, source: 'elephant', client: build(:client, created_at: 349.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_gyr_intake) { create(:intake, id: 2, source: 'llama', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_ctc_intake) { create(:ctc_intake, id: 3, source: 'giraffe', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:new_unconsented_ctc_intake) { create(:intake, id: 4, source: 'porcupine', client: build(:client, created_at: 1.hour.ago, consented_to_service_at: nil)) }
      let!(:old_consented_gyr_intake) { create(:intake, id: 5, source: 'fox', primary_consented_to_service: "yes", client: build(:client, created_at: 3.days.ago, consented_to_service_at: DateTime.now)) }

      it 'deletes clients where primary has not consented were created more than 2 days ago' do
        expect(Intake.all.map(&:id)).to match_array([old_unconsented_gyr_intake, old_unconsented_ctc_intake, new_unconsented_ctc_intake, old_consented_gyr_intake].map(&:id))

        RemoveUnconsentedClientsJob.new.perform

        expect(Intake.all.map(&:id)).to match_array([new_unconsented_ctc_intake, old_consented_gyr_intake].map(&:id))

        expect(AbandonedPreConsentIntake.all.map(&:id)).to match_array([old_unconsented_gyr_intake, old_unconsented_ctc_intake].map(&:id))
        abandoned_pre_consent_gyr_intake = AbandonedPreConsentIntake.find_by(id: old_unconsented_gyr_intake.id)
        expect(abandoned_pre_consent_gyr_intake.source).to eq('llama')
        expect(abandoned_pre_consent_gyr_intake.client_id).to eq(old_unconsented_gyr_intake.client_id)

        abandoned_pre_consent_ctc_intake = AbandonedPreConsentIntake.find_by(id: old_unconsented_ctc_intake.id)
        expect(abandoned_pre_consent_ctc_intake.source).to eq('giraffe')
        expect(abandoned_pre_consent_ctc_intake.client_id).to eq(old_unconsented_ctc_intake.client_id)

        # Oldschool archived clients/intakes are not deleted at this time
        expect(archived_intake.reload).to be
      end
    end
  end
end