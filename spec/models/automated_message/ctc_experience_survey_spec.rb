require 'rails_helper'

RSpec.describe AutomatedMessage::CtcExperienceSurvey do
  describe ".clients_to_survey" do
    let(:transition_time) { 25.hours.ago }
    let(:ctc_experience_survey_sent_at) { nil }
    let(:service_type) { 'online_intake' }
    let!(:client) do
      Timecop.freeze(transition_time) do
        create :tax_return, status, service_type: service_type, client: build(:client, ctc_experience_survey_sent_at: ctc_experience_survey_sent_at, intake: build(:ctc_intake, primary_consented_to_service: "yes"))
      end.client
    end
    let(:status) { :file_accepted }

    context "clients who should get the survey" do
      context "with a client who has had tax returns in certain terminal statuses for more than a day" do
        it "includes the client" do
          expect(described_class.clients_to_survey).to match_array([client])
        end
      end

      describe 'file_not_filing status' do
        let(:status) { :file_not_filing }
        let!(:old_enough_client) do
          Timecop.freeze((4.01).days.ago) do
            create :tax_return, status, service_type: service_type, client: build(:client, ctc_experience_survey_sent_at: ctc_experience_survey_sent_at, intake: build(:ctc_intake, primary_consented_to_service: "yes"))
          end.client
        end

        it "sends after four days" do
          expect(described_class.clients_to_survey).to match_array([old_enough_client])
        end
      end

      describe 'file_hold status' do
        let(:status) { :file_hold }
        let!(:old_enough_client) do
          Timecop.freeze((7.01).days.ago) do
            create :tax_return, status, service_type: service_type, client: build(:client, ctc_experience_survey_sent_at: ctc_experience_survey_sent_at, intake: build(:ctc_intake, primary_consented_to_service: "yes"))
          end.client
        end

        it "sends the survey after seven days" do
          expect(described_class.clients_to_survey).to match_array([old_enough_client])
        end
      end
    end

    context "clients who should not get the survey" do
      context "with a client who already received this survey" do
        let(:ctc_experience_survey_sent_at) { DateTime.now }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "with an intake that is a GYR intake" do
        before do
          client.intake.update(type: "Intake::GyrIntake")
        end

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end

      context "when a TaxReturn is ctc and drop off" do
        let(:service_type) { 'drop_off' }

        it "does not send the survey" do
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
        let(:transition_time) { 31.days.ago }

        it "does not include them" do
          expect(described_class.clients_to_survey).to be_empty
        end
      end
    end
  end
end
