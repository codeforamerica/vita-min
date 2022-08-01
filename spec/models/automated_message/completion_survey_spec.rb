require 'rails_helper'

RSpec.describe AutomatedMessage::CompletionSurvey do
  describe ".clients_to_survey" do
    let(:transition_time) { 25.hours.ago }
    let(:completion_survey_sent_at) { nil }
    let!(:tax_return) do
      Timecop.freeze(transition_time) do
        create :tax_return, status, client: build(:client, completion_survey_sent_at: completion_survey_sent_at, intake: build(:intake, primary_consented_to_service: "yes"))
      end
    end
    let(:status) { :file_accepted }

    context "clients who should get the survey" do
      context "with a client who has had tax returns in certain terminal statuses for more than a day" do
        it "includes the client" do
          expect(described_class.clients_to_survey).to include(tax_return.client)
        end
      end
    end

    context "clients who should not get the survey" do
      context "with a client who already received this survey" do
        let(:completion_survey_sent_at) { DateTime.now }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "with an intake that is a CTC intake" do
        before do
          tax_return.intake.update(type: "Intake::CtcIntake")
        end

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "with a tax return that is not in the appropriate status" do
        let(:status) { "intake_ready" }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "with a tax return that has been in the final state for less than a day" do
        let(:transition_time) { 1.hour.ago }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "with a tax return that has been in the final state for a very long time" do
        let(:transition_time) { 35.days.ago }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end
    end
  end
end
