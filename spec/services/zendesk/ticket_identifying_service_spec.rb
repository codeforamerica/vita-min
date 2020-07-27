require "rails_helper"

describe Zendesk::TicketIdentifyingService do
  let(:service) { described_class.new }

  def zendesk_double(
    id:, intake_status:,
    return_status:,
    updated_at: Time.now,
    group_id: "",
    status: "open",
    group: double("ZendeskAPI::Group", id: 1111, name: "Group")
  )
    double(
      ZendeskAPI::Ticket,
      id: id,
      errors: nil,
      status: status,
      updated_at: updated_at,
      group_id: group_id,
      group: group,
      fields: [
        double(ZendeskAPI::Trackie, id: EitcZendeskInstance::INTAKE_STATUS.to_i, value: intake_status ),
        double(ZendeskAPI::Trackie, id: EitcZendeskInstance::RETURN_STATUS.to_i, value: return_status )
      ],
    )
  end

  describe "#instance" do
    it "always uses the EITC zendesk instance" do
      expect(service.instance).to eq EitcZendeskInstance
    end
  end

  describe "#find_primary_ticket" do
    before do
      all_tickets.each do |ticket|
        allow(service).to receive(:get_ticket).with(ticket_id: ticket.id).and_return(ticket)
      end
    end

    context "when tickets have different indexed statuses" do
      let(:return_in_progress) do
        zendesk_double(
          id: 345,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
          updated_at: Time.new(2020, 4, 5)
        )
      end
      let(:intake_in_progress) do
        zendesk_double(
          id: 456,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        )
      end
      let(:ready_for_review) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_QUALITY_REVIEW,
        )
      end
      let(:gathering_docs) do
        zendesk_double(
          id: 789,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          updated_at: Time.new(2020, 3, 3)
        )
      end
      let(:closed) do
        zendesk_double(
          id: 567,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_EFILE,
          status: "closed"
        )
      end
      let(:all_tickets) do
        [return_in_progress, intake_in_progress, ready_for_review, gathering_docs, closed]
      end

      it "returns the Zendesk ticket with most advanced status" do
        ticket = service.find_primary_ticket([456, 789])

        expect(ticket).to eq gathering_docs

        ticket = service.find_primary_ticket([123, 345, 456, 789])

        expect(ticket).to eq ready_for_review
      end

      it "ignores closed tickets" do
        ticket = service.find_primary_ticket([123, 345, 456, 789, 567])

        expect(ticket).not_to eq closed
      end

      context "when some tickets are not found in Zendesk" do
        before do
          allow(service).to receive(:get_ticket)
            .with(ticket_id: ready_for_review.id)
            .and_return(nil)
        end

        it "returns nil and outputs the missing ticket id" do
          expect { @result = service.find_primary_ticket([123, 345, 456, 789]) }
            .to(output.to_stdout)
          expect(@result).to be_nil
        end
      end
    end

    context "when there are tickets with the same status" do
      let(:ready_for_review_new) do
        zendesk_double(
          id: 345,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_QUALITY_REVIEW,
          updated_at: Time.new(2020, 6, 5),
        )
      end
      let(:ready_for_review_old) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_QUALITY_REVIEW,
          updated_at: Time.new(2020, 6, 3),
        )
      end
      let(:all_tickets) do
        [ready_for_review_new, ready_for_review_old]
      end

      it "returns the most recently updated ticket" do
        ticket = service.find_primary_ticket([345, 123])

        expect(ticket).to eq ready_for_review_new
      end
    end

    context "when a ticket has an unindexed status (not filing)" do
      let(:not_filing) do
        zendesk_double(
          id: 345,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_NOT_FILING,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          updated_at: Time.new(2020, 6, 5),
        )
      end
      let(:intake_in_progress) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          updated_at: Time.new(2020, 6, 5),
        )
      end

      let(:all_tickets) { [not_filing, intake_in_progress] }

      it "selects any other status as primary" do
        result = service.find_primary_ticket([345, 123])

        expect(result).to eq intake_in_progress
      end
    end

    context "when all the tickets are closed" do
      let(:closed) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_EFILE,
          status: "closed"
        )
      end
      let(:closed_2) do
        zendesk_double(
          id: 234,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          status: "closed"
        )
      end
      let(:all_tickets) do
        [closed, closed_2]
      end

      it "returns nil" do
        result = service.find_primary_ticket([234, 123])

        expect(result).to be_nil
      end
    end
  end
end
