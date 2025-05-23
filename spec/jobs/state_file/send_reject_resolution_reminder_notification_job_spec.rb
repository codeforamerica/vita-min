require 'rails_helper'

RSpec.describe StateFile::SendRejectResolutionReminderNotificationJob, type: :job do
  describe "#perform" do
    let(:intake) {
      create :state_file_az_intake,
             efile_submissions: efile_submissions,
             primary_first_name: "Mona",
             email_address: "monalisa@example.com",
             email_address_verified_at: 1.minute.ago,
             hashed_ssn: "fake_hashed_ssn",
             message_tracker: {}
    }
    let(:current_state) { :notified_of_rejection }
    let(:efile_submissions) { [create(:efile_submission, current_state)] }
    let(:message) { StateFile::AutomatedMessage::RejectResolutionReminder }
    let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/questions/return-status" } }
    let(:sf_messaging_service) {
      StateFile::MessagingService.new(
        intake: intake,
        message: message,
        body_args: body_args)
    }

    before do
      allow(StateFile::MessagingService).to receive(:new).with(intake: intake, message: message, body_args: body_args).and_return(sf_messaging_service)
    end

    context "with an intake that has been sent a notified-of-rejection message, does not have an accepted return" do
      context "is currently in waiting state" do
        let(:current_state) { :waiting }
        before do
          efile_submissions.first.efile_submission_transitions.first.update(sort_key: 1)
          create(:efile_submission_transition, :notified_of_rejection, efile_submission: efile_submissions.first, most_recent: false, sort_key: 0)
        end

        it "sends the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")
          first_send_time = intake.message_tracker["messages.state_file.reject_resolution_reminder"]

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args)

          Timecop.freeze(10.days.from_now) do
            # can re-send if message was sent before (send 13th & 23rd in 2025)
            expect {
              described_class.perform_now(intake)
            }.to change(StateFileNotificationEmail, :count).by(1)

            expect(intake.message_tracker["messages.state_file.reject_resolution_reminder"]).not_to eq(first_send_time)

            expect(StateFile::MessagingService).to have_received(:new).with(
              intake: intake,
              message: message,
              body_args: body_args).exactly(2).times
          end
        end

        context "with unverified phone number" do
          before do
            intake.update(phone_number: "+13453432222", phone_number_verified_at: nil, sms_notification_opt_in: "yes", email_address: 'test@example.com', email_address_verified_at: 5.minutes.ago, email_notification_opt_in: "no")
          end

          it "should still send the message" do
            expect {
              described_class.perform_now(intake)
            }.to change(StateFileNotificationTextMessage, :count).by(1)

            expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

            expect(StateFile::MessagingService).to have_received(:new).with(
              intake: intake,
              message: message,
              body_args: body_args)
          end
        end
      end

      context "is currently in notified_of_rejection state" do
        let(:current_state) { :notified_of_rejection }

        it "sends the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")
          first_send_time = intake.message_tracker["messages.state_file.reject_resolution_reminder"]

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args)

          Timecop.freeze(10.days.from_now) do
            # can re-send if message was sent before (send 13th & 23rd in 2025)
            expect {
              described_class.perform_now(intake)
            }.to change(StateFileNotificationEmail, :count).by(1)

            expect(intake.message_tracker["messages.state_file.reject_resolution_reminder"]).not_to eq(first_send_time)

            expect(StateFile::MessagingService).to have_received(:new).with(
              intake: intake,
              message: message,
              body_args: body_args).exactly(2).times
          end
        end

        context "when another intake exists with the same hashed SSN" do
          let!(:other_intake) {
            create other_intake_class,
                   efile_submissions: other_efile_submissions,
                   primary_first_name: "Fona",
                   phone_number: "+15551234567",
                   phone_number_verified_at: 1.minute.ago,
                   hashed_ssn: intake.hashed_ssn,
                   message_tracker: {}
          }

          before do
            allow(Flipper).to receive(:enabled?).and_call_original
            allow(Flipper).to receive(:enabled?).with(:prevent_duplicate_ssn_messaging).and_return(true)
          end

          context "which has an efile submission" do
            let(:other_efile_submissions) { [create(:efile_submission, :accepted)] }

            context "and which was filed in the same state" do
              let(:other_intake_class) { :state_file_az_intake }

              it "does not send the message" do
                expect { described_class.perform_now(intake) }.not_to change(StateFileNotificationEmail, :count)
              end
            end

            context "and which was filed in another state" do
              let(:other_intake_class) { :state_file_nc_intake }

              it "does not send the message" do
                expect { described_class.perform_now(intake) }.not_to change(StateFileNotificationEmail, :count)
              end
            end
          end

          context "which does not have an efile submission" do
            let(:other_efile_submissions) { [] }
            let(:other_intake_class) { :state_file_az_intake }

            it "sends the message" do
              expect { described_class.perform_now(intake) }.to change(StateFileNotificationEmail, :count).by(1)
            end
          end
        end
      end
    end

    context "with an intake that has an accepted return" do
      let(:efile_submissions) { [create(:efile_submission, :notified_of_rejection), create(:efile_submission, :accepted)] }

      it "does not send the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(0)

        expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
      end
    end

    [:preparing, :bundling, :queued, :transmitted, :ready_for_ack, :failed, :accepted, :rejected, :investigating, :fraud_hold, :resubmitted, :cancelled].each do |state|
      context "currently in #{state} state which is not notified_of_rejection or waiting, even though it has notified_of_rejection in the past" do
        let(:current_state) { state }

        before do
          efile_submissions.first.efile_submission_transitions.first.update(sort_key: 1)
          create(:efile_submission_transition, :notified_of_rejection, efile_submission: efile_submissions.first, most_recent: false, sort_key: 0)
        end

        it "does not send the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(0)

          expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
        end
      end
    end
  end
end
