require 'rails_helper'

RSpec.describe SendClientInProgressSurveyJob, type: :job do
  describe "#perform" do
    # send to people that have been in "not ready" for 10 days and who have not sent any inbound messages
    # and (not uploaded any docs or not uploaded after 24 hours of intake creation)
    #   = (documents.where("created_at > ? ", intake.created_at + 1.day).empty?

    context "when a tax return has been in the `intake_in_progress` status for 10 days, does not have any inbound messages and has not uploaded any documents after 24 hours of intake creation" do
      let(:client) { create :client }
      let(:tax_return) { create :tax_return, status: "intake_in_progress", client: client }
      let(:intake) { create :intake, primary_consented_to_service_at: Time.utc(2021, 2, 6, 0, 0, 0) - 10.days, client: client }

      it "sends the survey" do
        Timecop.freeze(Time.utc(2021, 2, 6, 0, 0, 0)) do
          expect do
            tax_return.update!(status: "intake_in_progress")
          end.to have_enqueued_job(SendClientInProgressSurveyJob).with(tax_return.client)
        end
      end
    end
  end
end
