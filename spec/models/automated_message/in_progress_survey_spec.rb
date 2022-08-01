require 'rails_helper'

RSpec.describe AutomatedMessage::InProgressSurvey do
  describe ".clients_to_survey" do
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    context "clients who should get the survey" do
      context "with a client who has had tax returns in intake_in_progress for >10 days" do
        let!(:tax_return_in_scope) do
          Timecop.freeze(fake_time - 20.days) do
            create :tax_return, :intake_in_progress, client: create(:client, in_progress_survey_sent_at: nil, intake: create(:intake, primary_consented_to_service: "yes"))
          end
        end

        context "with no inbound messages or documents" do
          it "includes the client" do
            Timecop.freeze(fake_time) do
              expect(described_class.clients_to_survey).to include(tax_return_in_scope.client)
            end
          end
        end

        context "with a document added less than a day after intake creation" do
          let!(:document) { create :document, uploaded_by: tax_return_in_scope.client, client: tax_return_in_scope.client, created_at: tax_return_in_scope.client.intake.created_at + 10.minutes }

          it "includes the client" do
            Timecop.freeze(fake_time) do
              expect(described_class.clients_to_survey).to include(tax_return_in_scope.client)
            end
          end
        end
      end
    end

    context "clients who should not get the survey" do
      let!(:tax_return) { create :tax_return, status.to_sym, client: create(:client, in_progress_survey_sent_at: in_progress_survey_sent_at, intake: create(:intake, primary_consented_to_service: "yes")) }
      let(:status) { "intake_in_progress" }
      let(:in_progress_survey_sent_at) { nil }
      let(:primary_consented_to_service_at) { fake_time - 11.days }

      context "with an intake that is a CTC intake" do
        before do
          tax_return.intake.update(type: "Intake::CtcIntake")
        end

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
        end
      end

      context "with a tax return that does not have a intake_in_progress status" do
        let(:status) { "intake_ready" }
        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
        end
      end

      context "with a tax return that has been in progress for less than 10 days" do
        let(:primary_consented_to_service_at) { fake_time - 9.days }

        it "does not include them" do
          Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
        end
      end

      context "with a tax return that has been in progress for more than 10 days" do
        context "with a client that has inbound text messages" do
          let!(:inbound_text_message) { create :incoming_text_message, client: tax_return.client }

          it "does not include them" do
            Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
          end
        end

        context "for a client that has inbound email messages" do
          let!(:inbound_email) { create :incoming_email, client: tax_return.client }

          it "does not include them" do
            Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
          end
        end

        context "with a client that has uploaded a document more than one day after intake creation" do
          let!(:document) { create :document, uploaded_by: tax_return.client, client: tax_return.client, created_at: tax_return.client.intake.created_at + 1.day + 1.second }

          it "does not include them" do
            Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
          end
        end

        context "with a client who already received the survey" do
          let(:in_progress_survey_sent_at) { DateTime.current }
          it "is not included" do
            Timecop.freeze(fake_time) { expect(described_class.clients_to_survey).not_to include(tax_return.client) }
          end
        end
      end
    end
  end

end
