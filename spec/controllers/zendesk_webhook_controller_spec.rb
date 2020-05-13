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
    let!(:intake) {create :intake, intake_ticket_id: 9778}

    before do
      request.env["HTTP_AUTHORIZATION"] = valid_auth_credentials
      allow(subject).to receive(:send_mixpanel_event)
    end

    context "with valid params" do
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
            return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
            digital_intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
            ticket_via: "Web Service"
          }
        }
      end

      context "without any existing ticket statuses" do
        it "creates an initial ticket status with verified_change=false" do
          expect {post :incoming, params: params}
            .to change {intake.ticket_statuses.count}
                  .from(0).to(1)
          expect(intake.current_ticket_status.verified_change).to eq(false)
        end

        it "sends a mixpanel event with ticket status data and without default user data" do
          mixpanel_spy = spy(MixpanelService)
          allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
          expect(subject).to receive(:send_mixpanel_event).and_call_original
          post :incoming, params: params

          expected_mixpanel_data = {
            path: "/zendesk-webhook/incoming",
            full_path: "/zendesk-webhook/incoming",
            controller_name: "ZendeskWebhook",
            controller_action: "ZendeskWebhookController#incoming",
            controller_action_name: "incoming",
          }.merge(intake.mixpanel_data).merge(intake.current_ticket_status.mixpanel_data)

          expect(mixpanel_spy).to have_received(:run).with(
            unique_id: intake.visitor_id,
            event_name: "ticket_status_change",
            data: expected_mixpanel_data
          )
        end
      end

      context "if a ticket status exists for that intake" do
        context "if the intake and return status are the same" do
          before do
            create(:ticket_status,
                   intake: intake,
                   return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
                   intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
            )
          end

          it "does not create a new ticket status" do
            expect {post :incoming, params: params}
              .not_to change {intake.ticket_statuses.count}
          end

          it "does not send a mixpanel event" do
            post :incoming, params: params
            expect(subject).not_to have_received(:send_mixpanel_event)
          end
        end

        context "if the incoming status information is different than the current ticket status" do
          before do
            create(:ticket_status,
                   intake: intake,
                   return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
                   intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
                   )
          end

          it "creates a new ticket status with verified_change=true" do
            old_status = intake.current_ticket_status
            expect(old_status.intake_status).to eq EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS

            expect {post :incoming, params: params}
              .to change {intake.ticket_statuses.count}
                    .from(1).to(2)

            new_ticket_status = intake.reload.current_ticket_status
            expect(new_ticket_status.intake_status).to eq EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW
            expect(new_ticket_status.ticket_id).to eq(9778)
            expect(new_ticket_status.verified_change).to eq(true)
          end
        end
      end

      context "with multiple matching intakes" do
        let!(:second_intake) {create :intake, intake_ticket_id: 9778}

        it "adds a ticket status for all the matching intakes" do
          expect do
            post :incoming, params: params
          end.to change(TicketStatus, :count).from(0).to(2)
          linked_intakes = TicketStatus.all.pluck(:intake_id)
          expect(linked_intakes).to contain_exactly(intake.id, second_intake.id)
        end
      end
    end


    context "when the external id is empty" do
      let(:params) do
        {
          zendesk_webhook: {
            method: "updated_ticket",
            external_id: "",
            ticket_id: "9778",
            ticket_url: "eitc.zendesk.com/agent/tickets/9778",
            ticket_created_at: "2020-05-11T07:27:50-07:00",
            ticket_updated_at: "2020-05-11T07:27:50-07:00",
            ticket_tags: "pa",
            return_status: "",
            digital_intake_status: "",
            ticket_via: "Web Widget"
          }
        }
      end

      it "does not take action" do
        expect {post :incoming, params: params}
          .not_to change {intake.ticket_statuses.count}
      end
    end
  end
end
