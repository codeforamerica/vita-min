require "rails_helper"

describe RemoveUnconsentedClientsJob do
  describe "#perform" do
    context 'when there are barely started intakes' do
      let!(:old_unconsented_gyr_intake) { create(:intake, source: 'llama', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:old_unconsented_ctc_intake) { create(:ctc_intake, source: 'giraffe', client: build(:client, created_at: 19.days.ago, consented_to_service_at: nil)) }
      let!(:new_unconsented_ctc_intake) { create(:intake, source: 'porcupine', client: build(:client, created_at: 1.hour.ago, consented_to_service_at: nil)) }
      let!(:old_consented_gyr_intake) { create(:intake, source: 'fox', primary_consented_to_service: "yes", client: build(:client, created_at: 3.days.ago, consented_to_service_at: DateTime.now)) }

      it 'deletes clients where primary has not consented were created more than 2 days ago' do
        expect(Intake.all.map(&:id)).to match_array([old_unconsented_gyr_intake, old_unconsented_ctc_intake, new_unconsented_ctc_intake, old_consented_gyr_intake].map(&:id))

        RemoveUnconsentedClientsJob.new.perform

        expect(Intake.all.map(&:id)).to match_array([new_unconsented_ctc_intake, old_consented_gyr_intake].map(&:id))

        expect(AbandonedPreConsentIntake.all.map(&:id)).to match_array([old_unconsented_gyr_intake, old_unconsented_ctc_intake].map(&:id))
        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_gyr_intake.id).source).to eq('llama')
        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_gyr_intake.id).client_id).to eq(old_unconsented_gyr_intake.client_id)
        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_ctc_intake.id).source).to eq('giraffe')
        expect(AbandonedPreConsentIntake.find_by(id: old_unconsented_ctc_intake.id).client_id).to eq(old_unconsented_ctc_intake.client_id)
      end
    end
  end
end