require "rails_helper"

describe Zendesk::TicketMergingService do
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

  describe "#merge_duplicate_tickets" do
    let(:all_tickets) { [] }
    before do
      allow(service).to receive(:append_comment_to_ticket)
      all_tickets.each do |ticket|
        allow(service).to receive(:get_ticket).with(ticket_id: ticket.id).and_return(ticket)
      end
    end

    context "when tickets are in the same group" do
      let(:intake_in_progress) { create :intake, intake_ticket_id: 123 }
      let(:intake_in_progress_2) { create :intake, intake_ticket_id: 345 }
      let(:intake_closed) { create :intake, intake_ticket_id: 789 }
      let(:intake_ready_for_review) { create :intake, intake_ticket_id: 456 }
      let(:ticket_in_progress) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        )
      end
      let(:ticket_in_progress_2) do
        zendesk_double(
          id: 345,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        )
      end
      let(:ticket_ready_for_review) do
        zendesk_double(
          id: 456,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        )
      end
      let(:ticket_closed) do
        zendesk_double(
          id: 789,
          status: "closed",
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          )
      end
      let(:all_tickets) { [ticket_in_progress, ticket_in_progress_2, ticket_ready_for_review, ticket_closed] }

      before do
        allow(service).to receive(:find_primary_ticket).and_return(ticket_ready_for_review)
      end

      it "appends a comment to the primary ticket identifying the duplicate tickets" do
        service.merge_duplicate_tickets([intake_in_progress.id, intake_in_progress_2.id, intake_ready_for_review.id])

        comment_body = <<~BODY
          This client submitted multiple intakes. This is the most recent or complete ticket.
          These are the other tickets the client submitted:
          • https://eitc.zendesk.com/agent/tickets/123
          • https://eitc.zendesk.com/agent/tickets/345
        BODY
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 456,
          comment: comment_body,
          public: false,
        )
      end

      it "appends comments to the duplicate tickets and marks them as not filing" do
        service.merge_duplicate_tickets([intake_in_progress.id, intake_in_progress_2.id, intake_ready_for_review.id])

        comment_body = <<~BODY
          This client submitted multiple intakes. This ticket has been marked as "not filing" because it is a duplicate.
          The main ticket for this client is https://eitc.zendesk.com/agent/tickets/456
        BODY
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 123,
          comment: comment_body,
          public: false,
          fields: {
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
          }
        )
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 345,
          comment: comment_body,
          public: false,
          fields: {
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
          }
        )
      end

      it "does not attempt to append comments to duplicate tickets that are closed" do
        service.merge_duplicate_tickets([intake_in_progress.id, intake_in_progress_2.id, intake_ready_for_review.id, intake_closed.id])

        comment_body = <<~BODY
          This client submitted multiple intakes. This ticket has been marked as "not filing" because it is a duplicate.
          The main ticket for this client is https://eitc.zendesk.com/agent/tickets/456
        BODY

        expect(service).not_to have_received(:append_comment_to_ticket).with(
          ticket_id: 789,
          comment: comment_body,
          public: false,
          fields: {
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
          }
        )
      end

      it "links the intakes of the duplicate tickets to the primary ticket" do
        service.merge_duplicate_tickets([intake_in_progress.id, intake_in_progress_2.id, intake_ready_for_review.id])

        expect(intake_in_progress.reload.intake_ticket_id).to eq 456
        expect(intake_in_progress_2.reload.intake_ticket_id).to eq 456
      end

      it "links the intakes of the duplicate tickets to the primary intake" do
        service.merge_duplicate_tickets([intake_in_progress.id, intake_in_progress_2.id, intake_ready_for_review.id])

        expect(intake_in_progress.reload.primary_intake_id).to eq intake_ready_for_review.id
        expect(intake_in_progress_2.reload.primary_intake_id).to eq intake_ready_for_review.id
      end
    end

    context "when tickets are routed to different groups" do
      let(:intake_gathering_docs) { create :intake, intake_ticket_id: 123 }
      let(:intake_ready_for_review) { create :intake, intake_ticket_id: 456 }
      let(:old_group) { double("ZendeskAPI::Group", id: 1111, name: "Old Group") }
      let(:new_group) { double("ZendeskAPI::Group", id: 2222, name: "New Group") }
      let(:ticket_gathering_docs) do
        zendesk_double(
          id: 123,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          group: old_group,
        )
      end
      let(:ticket_ready_for_review) do
        zendesk_double(
          id: 456,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
          group: new_group,
        )
      end
      let(:all_tickets) { [ticket_gathering_docs, ticket_ready_for_review] }
      let(:all_groups) { [old_group, new_group] }

      before do
        allow(service).to receive(:find_primary_ticket).and_return(ticket_ready_for_review)
      end

      it "appends comments including the differing group assignments" do
        service.merge_duplicate_tickets([intake_gathering_docs.id, intake_ready_for_review.id])

        comment_body = <<~BODY
          This client submitted multiple intakes. This is the most recent or complete ticket.
          These are the other tickets the client submitted:
          • https://eitc.zendesk.com/agent/tickets/123 (assigned to Old Group)
        BODY
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 456,
          comment: comment_body,
          public: false,
        )

        comment_body = <<~BODY
          This client submitted multiple intakes. This ticket has been marked as "not filing" because it is a duplicate.
          The main ticket for this client is https://eitc.zendesk.com/agent/tickets/456 (assigned to New Group)
        BODY
        expect(service).to have_received(:append_comment_to_ticket).with(
          ticket_id: 123,
          comment: comment_body,
          public: false,
          fields: {
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
          }
        )
      end
    end

    context "when there is no primary ticket because all are closed" do
      let(:intake_closed) { create :intake, intake_ticket_id: 123 }
      let(:intake_closed_2) { create :intake, intake_ticket_id: 234 }
      before do
        allow(service).to receive(:find_primary_ticket).and_return(nil)
      end

      it "does nothing to the tickets" do
        output = service.merge_duplicate_tickets([intake_closed.id, intake_closed_2.id])

        expect(output).to be_nil
        expect(service).not_to have_received(:append_comment_to_ticket)
        expect(intake_closed.reload.intake_ticket_id).to eq 123
        expect(intake_closed_2.reload.intake_ticket_id).to eq 234
      end
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
