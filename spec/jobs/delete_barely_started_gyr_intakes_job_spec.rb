require "rails_helper"

describe DeleteUnconsentedClientsJob do
  describe "#perform" do
    context 'when there are barely started intakes' do
      let!(:old_unconsented_gyr_intake) { create :intake, client: create(:client, created_at: 3.days.ago, consented_to_service_at: nil, tax_returns: [create(:tax_return)]) }
      let!(:old_unconsented_ctc_intake) { create(:ctc_intake, client: create(:client, created_at: 3.days.ago, consented_to_service_at: nil)) }
      let!(:new_unconsented_ctc_intake) { create(:intake, client: create(:client, created_at: 1.hour.ago, consented_to_service_at: nil)) }
      let!(:old_consented_gyr_intake) { create(:intake, primary_consented_to_service: "yes", client: create(:client, created_at: 3.days.ago, consented_to_service_at: DateTime.now)) }

      it 'deletes clients where primary has not consented were created more than 2 days ago' do
        expect {
          DeleteUnconsentedClientsJob.new.perform
        }.to change(Intake::CtcIntake, :count).by(-1)
       .and change(Intake::GyrIntake, :count).by(-1)
       .and change(Client, :count).by(-2)
      end
    end
  end
end