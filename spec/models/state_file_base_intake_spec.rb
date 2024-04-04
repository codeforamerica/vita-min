require "rails_helper"

describe StateFileBaseIntake do
  describe "#synchronize_df_dependents_to_database" do
    it "reads in dependents and adds all of them to the database" do
      xml = File.read(Rails.root.join("spec/fixtures/files/fed_return_five_dependents_ny.xml"))
      intake = create(:minimal_state_file_az_intake, raw_direct_file_data: xml)
      expect(intake.dependents).to be_blank
      intake.synchronize_df_dependents_to_database

      expect(intake.dependents.count).to eq 5
    end
  end

  describe "#timedout?" do
    let!(:intake) { create :state_file_az_intake }
    let!(:efile_submission) { create :efile_submission, data_source_id: intake.id, data_source_type: "StateFileAzIntake" }

    context "when timed out" do
      let!(:intake) { create :state_file_az_intake }
      it "actually times out" do
        # Confusingly, timedout?(15.minutes.ago) actually means: 'With the last accessed at of the
        # timestamp given, are we now timed out?'
        expect(intake.timedout?(14.minutes.ago)).to eq false
        expect(intake.timedout?(15.minutes.ago)).to eq true
        expect(intake.timedout?(16.minutes.ago)).to eq true
      end
    end
  end

  describe 'is_state_file_email?' do
    let!(:email) { 'email@test.com' }
    let!(:intake) { create :state_file_az_intake, email_address: email }

    context 'when is a FYST email' do
      it 'returns true' do
        expect(StateFileBaseIntake.is_state_file_email?(email)).to eq true
      end
    end

    context 'when is NOT a FYST email' do
      it 'returns false' do
        expect(StateFileBaseIntake.is_state_file_email?('another_email@test.com')).to eq false
      end
    end
  end
end
