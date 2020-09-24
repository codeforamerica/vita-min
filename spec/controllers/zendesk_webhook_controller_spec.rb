require "rails_helper"

RSpec.describe ZendeskWebhookController, type: :controller do
  let(:valid_auth_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("testname", "n1c3!")
  end

  let(:invalid_auth_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("l33tH4x0r", "k3rn3l_k!d")
  end

  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:zendesk_webhook_auth, :name).and_return("testname")
    allow(EnvironmentCredentials).to receive(:dig).with(:zendesk_webhook_auth, :password).and_return("n1c3!")
  end

  describe "#incoming" do
    let(:params) do
      {
        zendesk_webhook: {
          external_id: "intake-111",
          ticket_id: "1000",
          ticket_url: "test.zendesk.biz/agent/tickets/1000",
          ticket_created_at: "2020-02-19T14:05:27-07:00",
          ticket_updated_at: "2020-04-01T20:41:18-07:00",
          ticket_tags: "",
          return_status: "",
          digital_intake_status: "",
          ticket_via: "Web Service"
        }
      }
    end

    context "with HTTP basic auth credentials" do
      before do
        request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
      end

      it "returns 200" do
        post :incoming, params: params

        expect(response.status).to eq 200
      end
    end

    context "without valid HTTP basic auth credentials" do
      before {request.env["HTTP_AUTHORIZATION"] = invalid_auth_credentials}
      it "returns 401 Not Authorized" do
        post :incoming, params: params

        expect(response.status).to eq 401
      end
    end
  end

  describe "#incoming_sms", active_job: true do
    before do
      request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
    end

    context "with valid params" do
      let(:params) do
        {
          zendesk_webhook: {
            method: "updated_sms",
            requester_phone_number: "+15552341122",
            requester_id: "401010335794",
            message_body: "sms_test heyo!\nsome other stuff on a new line",
            ticket_id: "1000",
            ticket_url: "test.zendesk.biz/agent/tickets/1000",
            ticket_created_at: "2020-02-19T14:05:27-07:00",
            ticket_updated_at: "2020-04-01T20:41:18-07:00",
            ticket_via: "SMS"
          }
        }
      end

      it "enqueues an inbound sms job" do
        post :incoming, params: params

        expect(ZendeskInboundSmsJob).to have_been_enqueued.with(
          sms_ticket_id: 1000,
          phone_number: "15552341122",
          message_body: "sms_test heyo!\nsome other stuff on a new line",
        )
      end
    end
  end

  describe "#updated_ticket", active_job: true do
    let!(:intake) { create :intake, intake_ticket_id: 9778 }

    before do
      request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
    end

    context "with valid params for a full intake" do
      let(:params) do
        {
          zendesk_webhook: {
            method: "updated_ticket",
            external_id: "intake-#{intake.id}",
            ticket_id: "9778",
            ticket_url: "eitc.zendesk.com/agent/tickets/9778",
            ticket_created_at: "2020-05-11T07:27:50-07:00",
            ticket_updated_at: "2020-05-11T07:27:50-07:00",
            ticket_tags: "online_intake_ready_for_intake_interview pa",
            eip_return_status: "",
            return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
            digital_intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
            ticket_via: "Web Service"
          }
        }
      end

      it "enqueues an update zendesk ticket status job" do
        post :incoming, params: params

        expect(UpdateZendeskTicketStatusJob).to have_been_enqueued.with(params[:zendesk_webhook])
      end
    end
  end
end
