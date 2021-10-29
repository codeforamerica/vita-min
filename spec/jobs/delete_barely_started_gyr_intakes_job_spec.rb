require "rails_helper"

describe DeleteBarelyStartedGyrIntakesJob do
  describe "#perform" do
    context 'when there are barely started intakes' do
      let!(:old_unconsented_gyr_intake) { create :intake, primary_consented_to_service_at: nil, created_at: 15.days.ago, client: create(:client, tax_returns: [create(:tax_return)]) }
      let!(:old_unconsented_ctc_intake) { create(:ctc_intake, primary_consented_to_service_at: nil, created_at: 15.days.ago) }
      let!(:new_unconsented_ctc_intake) { create(:intake, primary_consented_to_service_at: nil, created_at: 1.day.ago) }
      let!(:old_consented_gyr_intake) { create(:intake, primary_consented_to_service_at: 1.day.ago, primary_consented_to_service: "yes", created_at: 15.days.ago) }

      it 'deletes GYR intakes that have not reached the consent page and were created more than 14 days ago' do
        expect {
          DeleteBarelyStartedGyrIntakesJob.new.perform
        }.to change(Intake, :count).by -1

        expect(Intake.find_by(id: old_unconsented_gyr_intake.id)).to be_nil
      end

      it 'deletes clients and tax returns associated with that intake' do
        expect do
          DeleteBarelyStartedGyrIntakesJob.new.perform
        end.to change(Client, :count).by(-1).and change(TaxReturn, :count).by(-1)

        expect(Client.find_by(id: old_unconsented_gyr_intake.client.id)).to be_nil
        expect(TaxReturn.find_by(id: old_unconsented_gyr_intake.client.tax_returns.first.id)).to be_nil
      end
    end
  end
end