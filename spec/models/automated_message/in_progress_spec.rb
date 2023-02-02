require "rails_helper"

RSpec.describe AutomatedMessage::InProgress do
  describe ".clients_to_message" do
    let(:status) { :intake_in_progress }
    let(:in_progress_survey_sent_at) { nil }
    let(:consented_to_service_at) { 30.minutes.ago }
    let!(:client) do
      (
        create :gyr_tax_return,
               status,
               client:
                 create(
                   :client,
                   in_progress_survey_sent_at: in_progress_survey_sent_at,
                   consented_to_service_at: consented_to_service_at,
                   intake: create(:intake, primary_consented_to_service: "yes")
                 )
      ).client
    end

    let!(:ctc_client_that_will_never_be_included) do
      (
        create :ctc_tax_return,
               status,
               client:
                 create(
                   :client,
                   in_progress_survey_sent_at: in_progress_survey_sent_at,
                   consented_to_service_at: consented_to_service_at,
                   intake: create(:ctc_intake, primary_consented_to_service: "yes")
                 )
      ).client
    end

    context "clients who should get the message" do
      context "who has had tax returns in 'intake_in_progress' and has been created at least half an hour ago" do
        context "who has not received a message before" do
          it "includes the client" do
            expect(described_class.clients_to_message(Time.current)).to match_array([client])
          end
        end
        
        context "who has received a message before" do
          let(:in_progress_survey_sent_at) { 7.minutes.ago }
          it "does not includes the client" do
            expect(described_class.clients_to_message(Time.current)).to be_empty
          end
        end
      end

      context "who has had tax returns in 'intake_needs_doc_help' and has been created at least half an hour ago" do
        let(:status) { :intake_needs_doc_help }

        it "includes the client" do
          expect(described_class.clients_to_message(Time.current)).to match_array([client])
        end
      end
    end

    context "clients who should not get the message" do
      context "who has no tax returns in 'intake_in_progress'" do
        let(:status) { :intake_ready }
        it "does not includes the client" do
          expect(described_class.clients_to_message(Time.current)).to be_empty
        end
      end

      context "who has had tax returns in 'intake_in_progress' and has been created at most half an hour ago" do
        let(:consented_to_service_at) { 5.minutes.ago }
        context "who has received a message before" do
          it "does not includes the client" do
            expect(described_class.clients_to_message(Time.current)).to be_empty
          end
        end
      end

      context "who has consented for more than a day ago" do
        let(:consented_to_service_at) { 25.hours.ago }

        it "does not include the client" do
          expect(described_class.clients_to_message(Time.current)).to be_empty
        end
      end
    end
  end
end
