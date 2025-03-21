require 'rails_helper'

describe StateFile::ReminderToFinishStateReturnService do
  describe ".run" do
    let(:message) { StateFile::AutomatedMessage::FinishReturn }
    let(:state_file_messaging_service) { StateFile::MessagingService.new(intake: intake, message: message) }

    before do
      allow(StateFile::MessagingService).to receive(:new).with(intake: intake, message: message).and_return(state_file_messaging_service)
      allow(state_file_messaging_service).to receive(:send_message)
    end

    context "when there is an incomplete intake with df transfer from exactly 6 hours ago" do
      let!(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 6.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: "dezie@example.com",
               message_tracker: {}
      end

      it "sends a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, message: message)
        expect(state_file_messaging_service).to have_received(:send_message)
      end
    end

    context "when there is an incomplete intake with df transfer from less than 6 hours ago" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: (5.hours + 59.minutes).ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: "dezie@example.com"
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an intake that has been submitted (has an efile submission)" do
      let!(:intake) { create :state_file_az_intake, df_data_imported_at: 12.hours.ago }
      let!(:submission) { create :efile_submission, :for_state, data_source: intake }

      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake with from another year" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: "rayploshansky@example.com",
               created_at: 2.years.ago
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake with from New York" do
      let(:intake) do
        create :state_file_ny_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: "rayploshansky@example.com"
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that has already been sent a finish return message" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: "rayploshansky@example.com",
               message_tracker: {"messages.state_file.finish_return" => "2024-11-06 21:14:49 UTC"}
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that email has not been verified" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: nil,
               email_notification_opt_in: "yes",
               email_address: "rayploshansky@example.com"
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that has not opted into emails" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "unfilled",
               email_address: "rayploshansky@example.com"
      end
      it "does not send a message to the email associated with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that does not have an email" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               email_address_verified_at: 7.hours.ago,
               email_notification_opt_in: "yes",
               email_address: nil
      end
      it "does not send a message to the phone number with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that phone number has not been verified" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               phone_number_verified_at: nil,
               sms_notification_opt_in: "yes",
               phone_number: "+14155551212"
      end
      it "does not send a message to the phone number with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that has not opted into sms messages" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               phone_number_verified_at: 7.hours.ago,
               sms_notification_opt_in: "unfilled",
               phone_number: "+14155551212"
      end
      it "does not send a message to the phone number with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

    context "when there is an incomplete intake that does not have a phone number" do
      let(:intake) do
        create :state_file_az_intake,
               df_data_imported_at: 7.hours.ago,
               phone_number_verified_at: 7.hours.ago,
               sms_notification_opt_in: "yes",
               phone_number: nil
      end
      it "does not send a message to the phone number with the intake" do
        StateFile::ReminderToFinishStateReturnService.run
        expect(StateFile::MessagingService).to_not have_received(:new)
      end
    end

  end
end
