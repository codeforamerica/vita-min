require "rails_helper"

RSpec.describe UpdateZendeskTicketStatusJob, type: :job do
  describe "#perform" do
    let!(:intake) { create :intake, intake_ticket_id: 9778 }

    context "with a valid json for a full intake" do
      let(:json_payload) do
        {
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
      end

      context "without any existing ticket statuses" do
        it "creates an initial ticket status with verified_change=false" do
          expect do
            described_class.perform_now(json_payload)
          end.to change { intake.ticket_statuses.count }.from(0).to(1)
          expect(intake.current_ticket_status.verified_change).to eq(false)
        end

        it "does not send a mixpanel event" do
          expect(MixpanelService).not_to receive(:send_event)
          described_class.perform_now(json_payload)
        end
      end

      context "if a ticket status exists for that intake" do
        context "if the intake and return status are the same" do
          before do
            create(
              :ticket_status,
              intake: intake,
              return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
              intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
           )
          end

          it "does not create a new ticket status" do
            expect do
              described_class.perform_now(json_payload)
            end.not_to change { intake.ticket_statuses.count }
          end
        end

        context "if the incoming status information is different than the current ticket status" do
          before do
            create(
              :ticket_status,
              intake: intake,
              return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
              intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
            )
          end

          it "creates a new ticket status with verified_change=true" do
            expect do
              described_class.perform_now(json_payload)
            end.to change { intake.ticket_statuses.count }.from(1).to(2)

            new_ticket_status = intake.reload.current_ticket_status
            expect(new_ticket_status.intake_status).to eq EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW
            expect(new_ticket_status.ticket_id).to eq(9778)
            expect(new_ticket_status.verified_change).to eq(true)
          end

          it "sends a mixpanel event with intake and ticket status data" do
            allow(MixpanelService).to receive(:send_event)
            described_class.perform_now(json_payload)

            expect(MixpanelService).to have_received(:send_event).with(
              hash_including(event_name: "ticket_status_change")
            )
          end
        end
      end

      context "with multiple matching intakes" do
        let!(:second_intake) {create :intake, intake_ticket_id: 9778}

        it "adds a ticket status for all the matching intakes" do
          expect do
            described_class.perform_now(json_payload)
          end.to change(TicketStatus, :count).from(0).to(2)
          linked_intake_ids = TicketStatus.all.pluck(:intake_id)
          expect(linked_intake_ids).to contain_exactly(intake.id, second_intake.id)
        end
      end
    end

    context "with a valid json for an EIP-only Zendesk ticket" do
      let(:json_payload) do
        {
          method: "updated_ticket",
          external_id: "intake-#{intake.id}",
          ticket_id: "9778",
          ticket_url: "eitc.zendesk.com/agent/tickets/9778",
          ticket_created_at: "2020-05-11T07:27:50-07:00",
          ticket_updated_at: "2020-05-11T07:27:50-07:00",
          ticket_tags: "",
          eip_return_status: EitcZendeskInstance::EIP_STATUS_ID_UPLOAD,
          return_status: "",
          digital_intake_status: "",
          ticket_via: "Web Service"
        }
      end

      context "without any existing ticket statuses" do
        it "creates an initial ticket status with verified_change=false" do
          expect do
            described_class.perform_now(json_payload)
          end.to change { intake.ticket_statuses.count }.from(0).to(1)
          expect(intake.current_ticket_status.verified_change).to eq(false)
        end

        it "does not send a mixpanel event" do
          expect(MixpanelService).not_to receive(:instance)
          described_class.perform_now(json_payload)
        end
      end

      context "if a ticket status exists for that intake" do
        let(:eip_status) { EitcZendeskInstance::EIP_STATUS_ID_UPLOAD }
        before do
          create(
            :ticket_status,
            intake: intake,
            eip_status: eip_status,
          )
        end

        context "if the eip status is unchanged" do
          it "does not create a new ticket status" do
            expect do
              described_class.perform_now(json_payload)
            end.not_to change { intake.ticket_statuses.count }
          end
        end

        context "if the incoming status information is different than the current ticket status" do
          let(:eip_status) { EitcZendeskInstance::EIP_STATUS_SUBMITTED }

          it "creates a new ticket status with verified_change=true" do
            expect do
              described_class.perform_now(json_payload)
            end.to change { intake.ticket_statuses.count }.from(1).to(2)

            new_ticket_status = intake.reload.current_ticket_status
            expect(new_ticket_status.eip_status).to eq EitcZendeskInstance::EIP_STATUS_ID_UPLOAD
            expect(new_ticket_status.ticket_id).to eq(9778)
            expect(new_ticket_status.verified_change).to eq(true)
          end

          it "sends a mixpanel event with eip status data" do
            allow(MixpanelService).to receive(:send_event)
            described_class.perform_now(json_payload)

            expected_mixpanel_data = {
                verified_change: true,
                ticket_id: 9778,
                eip_status: "Reached ID upload page",
                created_at: instance_of(String),
            }

            expect(MixpanelService).to have_received(:send_event).with(
              hash_including(event_name: "ticket_status_change", data: hash_including(expected_mixpanel_data))
            )
          end
        end
      end
    end

    context "when the external id is empty" do
      let(:json_payload) do
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
        expect do
          described_class.perform_now(json_payload)
        end.not_to change { intake.ticket_statuses.count }
      end
    end
  end

end
