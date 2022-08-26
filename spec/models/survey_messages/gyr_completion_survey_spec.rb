require 'rails_helper'

RSpec.describe SurveyMessages::GyrCompletionSurvey do
  describe ".clients_to_survey" do
    let!(:client) do
      (create :tax_return, :intake_in_progress, client: build(:client, completion_survey_sent_at: completion_survey_sent_at, intake: build(:intake, primary_consented_to_service: "yes"))).client
    end
    let(:completion_survey_sent_at) { nil }
    let(:status) { nil }
    let(:expected_send_time) { 25.hours.from_now }
    let(:too_early_dont_send_time) { expected_send_time - 1.day }
    let(:too_stale_dont_send_time) { expected_send_time + 31.days }

    before do
      client.tax_returns.last.transition_to(status)
    end

    context "clients who should get the survey" do
      let(:status) { "file_accepted" }

      context "with a client whose tax returns are all in a terminal statuses for more than a day" do
        it "includes the client" do
          expect(described_class.clients_to_survey(expected_send_time)).to match_array([client])
        end
      end
    end

    context "clients who should not get the survey" do
      let(:status) { "file_accepted" }

      context "a client whose tax returns are all in terminal statuses" do
        context "but has been in status for less than a day" do
          it "excludes the client" do
            expect(described_class.clients_to_survey(too_early_dont_send_time)).to be_empty
          end
        end

        context "but has been in status for more than 30 days" do
          let(:status) { "file_accepted" }

          it "excludes the client" do
            expect(described_class.clients_to_survey(too_stale_dont_send_time)).to be_empty
          end
        end

        context "has already received this survey" do
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
      end

      context "with a tax return that is not in the appropriate status" do
        before do
          create(:tax_return, :intake_ready, year: 2020, client: client)
        end

        it "does not include them" do
          expect(described_class.clients_to_survey(expected_send_time)).to be_empty
        end
      end
    end
  end
end
