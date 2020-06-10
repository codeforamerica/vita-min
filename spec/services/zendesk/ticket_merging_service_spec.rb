require "rails_helper"

describe Zendesk::TicketMergingService do
  let(:service) { described_class.new }

  describe "#instance" do
    it "always uses the EITC zendesk instance" do
      expect(service.instance).to eq EitcZendeskInstance
    end
  end

  describe "#find_prime_ticket" do
    let(:intake_return_in_progress) { create :intake, intake_ticket_id: return_in_progress.id }
    let(:intake_in_progress) { create :intake, intake_ticket_id: intake_in_progress.id }
    let(:intake_ready_for_review) { create :intake, intake_ticket_id: ready_for_review.id }
    let(:intake_gathering_docs) { create :intake, intake_ticket_id: gathering_docs.id }
    let(:return_in_progress) do
      zendesk_double(
        id: 345,
        intake_status: EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
        return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
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

    before do
      all_tickets.each do |ticket|
        allow(service).to receive(:get_ticket).with(ticket_id: ticket.id).and_return(ticket)
      end
    end

    it "returns the Zendesk ticket with most advanced status" do
      ticket = service.find_prime_ticket([456, 789])

      expect(ticket).to eq gathering_docs

      ticket = service.find_prime_ticket([123, 345, 456, 789])

      expect(ticket).to eq ready_for_review
    end

    it "ignores closed tickets" do
      ticket = service.find_prime_ticket([123, 345, 456, 789, 567])

      expect(ticket).not_to eq closed
    end

  end

  def zendesk_double(id:, intake_status:, return_status:, status: "open")
    double(
      ZendeskAPI::Ticket,
      id: id,
      errors: nil,
      status: status,
      fields: [
        double(ZendeskAPI::Trackie, id: EitcZendeskInstance::INTAKE_STATUS.to_i, value: intake_status ),
        double(ZendeskAPI::Trackie, id: EitcZendeskInstance::RETURN_STATUS.to_i, value: return_status )
      ]
    )
  end
end
