require "rails_helper"

RSpec.describe AutomatedMessage::InProgress do
  describe ".clients_to_message" do
    let(:expected_send_time) { 30.minutes.from_now }
    let(:status) { :intake_in_progress }
    let(:in_progress_survey_sent_at) { nil }
    let!(:client) do
      (
        create :gyr_tax_return,
               status,
               client:
                 create(
                   :client,
                   in_progress_survey_sent_at: in_progress_survey_sent_at,
                   intake: create(:intake, primary_consented_to_service: "yes")
                 )
      ).client
    end

    context "clients who should get the survey" do
      context "with a client who has had tax returns in intake_in_progress for >10 days" do
        context "with no inbound messages or documents" do
          it "includes the client" do
            expect(
              described_class.clients_to_message(expected_send_time - 1.day)
            ).to be_empty
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to include(client)
          end
        end

        context "with a document added less than a day after intake creation" do
          let!(:document) do
            create :document,
                   uploaded_by: client,
                   client: client,
                   created_at: client.intake.created_at + 10.minutes
          end

          it "includes the client" do
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to include(client)
          end
        end
      end
    end

    context "clients who should not get the survey" do
      context "with an intake that is a CTC intake" do
        before { client.intake.update(type: "Intake::CtcIntake") }

        it "does not include them" do
          expect(
            described_class.clients_to_message(expected_send_time)
          ).to be_empty
        end
      end

      context "with a tax return that does not have a intake_in_progress status" do
        let(:status) { "intake_ready" }
        it "does not include them" do
          expect(
            described_class.clients_to_message(expected_send_time)
          ).to be_empty
        end
      end

      context "with a tax return that has been in progress for more than 10 days" do
        context "with a client that has inbound text messages" do
          let!(:inbound_text_message) do
            create :incoming_text_message, client: client
          end

          it "does not include them" do
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to be_empty
          end
        end

        context "for a client that has inbound email messages" do
          let!(:inbound_email) { create :incoming_email, client: client }

          it "does not include them" do
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to be_empty
          end
        end

        context "with a client that has uploaded a document more than one day after intake creation" do
          let!(:document) do
            create :document,
                   uploaded_by: client,
                   client: client,
                   created_at: client.intake.created_at + 1.day + 1.second
          end

          it "does not include them" do
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to be_empty
          end
        end

        context "with a client who already received the survey" do
          let(:in_progress_survey_sent_at) { DateTime.current }

          it "is not included" do
            expect(
              described_class.clients_to_message(expected_send_time)
            ).to be_empty
          end
        end
      end
    end
  end
end
