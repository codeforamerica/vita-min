require "rails_helper"

describe StateFileBaseIntake do

  describe ".return_status" do
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
  end
end
