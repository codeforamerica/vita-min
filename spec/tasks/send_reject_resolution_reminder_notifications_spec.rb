require "rails_helper"

describe "send_reject_resolution_reminder_notifications:send" do
  let!(:intake) { create :state_file_az_intake, efile_submissions: efile_subimissions }
  before do
    allow(StateFile::SendRejectResolutionReminderNotificationJob).to receive(:perform_later).with(intake)
  end

  include_context "rake"
  context "clients that have been notified of rejection but have no accepted return" do
    let(:efile_subimissions) { [create(:efile_submission, :notified_of_rejection)] }

    it "enqueues a job" do
      task.invoke
      expect(StateFile::SendRejectResolutionReminderNotificationJob).to have_received(:perform_later).with(intake)
    end
  end

  context "clients that have not been notified of rejection" do
    let(:efile_subimissions) { [create(:efile_submission, :transmitted)] }

    it "doesn't enqueues a job" do
      task.invoke
      expect(StateFile::SendRejectResolutionReminderNotificationJob).not_to have_received(:perform_later).with(intake)
    end
  end

  context "clients that have been accepted" do
    let(:efile_subimissions) { [create(:efile_submission, :accepted), create(:efile_submission, :notified_of_rejection)] }

    it "doesn't enqueues a job" do
      task.invoke
      expect(StateFile::SendRejectResolutionReminderNotificationJob).not_to have_received(:perform_later).with(intake)
    end
  end
end
