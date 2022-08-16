require 'rails_helper'

RSpec.describe SurveyMessages::GyrCompletionSurvey do
  describe ".clients_to_survey" do
    let(:completion_survey_sent_at) { nil }
    let!(:client) do
      (create :tax_return, status, client: build(:client, completion_survey_sent_at: completion_survey_sent_at, intake: build(:intake, primary_consented_to_service: "yes"))).client
    end
    let(:status) { :file_accepted }
    let(:expected_send_time) { 25.hours.from_now }
    let(:too_stale_dont_send_time) { expected_send_time + 31.days }

    context "clients who should get the survey" do
      context "with a client who has had tax returns in certain terminal statuses for more than a day" do
        it "includes the client" do
          expect(described_class.clients_to_survey(expected_send_time - 1.day)).to be_empty
          expect(described_class.clients_to_survey(expected_send_time)).to match_array([client])
          expect(described_class.clients_to_survey(too_stale_dont_send_time)).to be_empty
        end
      end
    end

    context "clients who should not get the survey" do
      context "with a client who already received this survey" do
        let(:completion_survey_sent_at) { DateTime.now }

        it "does not include them" do
          expect(described_class.clients_to_survey(expected_send_time)).to be_empty
        end
      end

      context "with an intake that is a CTC intake" do
        before do
          client.intake.update(type: "Intake::CtcIntake")
        end

        it "does not include them" do
          expect(described_class.clients_to_survey(expected_send_time)).to be_empty
        end
      end

      context "with a tax return that is not in the appropriate status" do
        let(:status) { "intake_ready" }

        it "does not include them" do
          expect(described_class.clients_to_survey(expected_send_time)).to be_empty
        end
      end
    end
  end
end
