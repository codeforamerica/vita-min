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

  describe "#return_status" do
    let!(:intake) { create :state_file_az_intake }
    let!(:efile_submission) { create :efile_submission, data_source_id: intake.id, data_source_type: "StateFileAzIntake" }

    context "with an accepted return" do
      before { allow_any_instance_of(EfileSubmission).to receive(:current_state).and_return('accepted') }

      it "it is accepted" do
        expect(intake.return_status).to eq('accepted')
      end
    end

    context "with a rejected return" do
      before { allow_any_instance_of(EfileSubmission).to receive(:current_state).and_return('rejected') }
      it "it is rejected" do
        expect(intake.return_status).to eq('rejected')
      end
    end

    context "with a bundling return" do
      before { allow_any_instance_of(EfileSubmission).to receive(:current_state).and_return('bundling') }
      it "it is pending" do
        expect(intake.return_status).to eq('pending')
      end
    end

    context "with a preparing return" do
      before { allow_any_instance_of(EfileSubmission).to receive(:current_state).and_return('preparing') }
      it "it is pending" do
        expect(intake.return_status).to eq('pending')
      end
    end

    context "with a resubmitted return" do
      before { allow_any_instance_of(EfileSubmission).to receive(:current_state).and_return('resubmitted') }
      it "it is pending" do
        expect(intake.return_status).to eq('pending')
      end
    end

    context "when timed out" do
      let!(:intake) { create :state_file_az_intake }
      it "actually times out" do
        # So oddly enough timedout?(15.minutes.ago) actually means 'Times out in 15 minutes'
        expect(intake.timedout?(14.minutes.ago)).to eq false
        expect(intake.timedout?(15.minutes.ago)).to eq true
        expect(intake.timedout?(16.minutes.ago)).to eq true
      end
    end
  end
end
