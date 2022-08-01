require 'rails_helper'

RSpec.describe AutomatedMessage::CompletionSurvey do
  describe ".clients_to_survey" do
    let(:transition_time) { fake_time - 25.hours }
    let(:fake_time) { Time.utc(2022, 8, 1, 0, 0, 0) }
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
          Timecop.freeze(fake_time) do
            expect(described_class.clients_to_survey).to include(tax_return.client)
          end
        end
      end
    end

    context "clients who should not get the survey" do
      context "with an intake that is a CTC intake" do
        before do
          tax_return.intake.update(type: "Intake::CtcIntake")
        end

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).to be_empty }
        end
      end

      context "with a tax return that is not in the appropriate status" do
        let(:status) { "intake_ready" }

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).to be_empty }
        end
      end

      context "with a tax return that has been in the final state for less than a day" do
        let(:transition_time) { fake_time - 1.hour }

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).to be_empty }
        end
      end

      context "with a tax return that has been in the final state for a very long time" do
        # TODO: See if we can remove this entirely - query prod to see.
        let(:transition_time) { Date.new(2022, 7, 1) }

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).to be_empty }
        end
      end
    end
  end
end
