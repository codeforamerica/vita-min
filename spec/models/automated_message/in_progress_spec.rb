require "rails_helper"

RSpec.describe AutomatedMessage::InProgress do
  describe ".clients_to_message" do
    let(:expected_send_time) { 31.minutes.from_now }
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

    context "clients who should get the message" do
      context "who has had tax returns in 'intake_in_progress' and has been created at least half an hour ago" do
        context "who has not received a message before" do
          it "includes the client" do
            expect(described_class.clients_to_message(expected_send_time)).to include(client)
          end
        end
        
        context "who has received a message before" do
          let(:in_progress_survey_sent_at) { 7.minutes.ago }
          it "does not includes the client" do
            expect(described_class.clients_to_message(expected_send_time)).not_to include(client)
          end
        end
      end
    end

    context "clients who should not get the message" do
      context "who has no tax returns in 'intake_in_progress'" do
        let(:status) { :intake_ready }
        it "does not includes the client" do
          expect(described_class.clients_to_message(expected_send_time)).to be_empty
        end
      end

      context "who has had tax returns in 'intake_in_progress' and has been created at most half an hour ago" do
        let(:expected_send_time) { 5.minutes.from_now }
        context "who has received a message before" do
          it "does not includes the client" do
            expect(described_class.clients_to_message(expected_send_time)).to be_empty
          end
        end
      end
    end
  end
end
