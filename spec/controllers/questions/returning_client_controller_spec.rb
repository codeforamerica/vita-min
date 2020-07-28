require "rails_helper"

RSpec.describe Questions::ReturningClientController do
  let(:intake) { create :intake }
  let(:duplicate_intake_guard_spy) { instance_double(DuplicateIntakeGuard) }

  describe ".show?" do
    before do
      allow(DuplicateIntakeGuard).to receive(:new).with(intake).and_return duplicate_intake_guard_spy
    end

    context "when intake has duplicate" do
      before do
        allow(duplicate_intake_guard_spy).to receive(:has_duplicate?).and_return true
      end

      it { expect(subject.class.show?(intake)).to eq true }
    end

    context "when intake has no duplicate" do
      before do
        allow(duplicate_intake_guard_spy).to receive(:has_duplicate?).and_return false
      end

      it { expect(subject.class.show?(intake)).to eq false }
    end
  end

  describe "#edit" do
    let(:fake_identifying_service) { Zendesk::TicketIdentifyingService.new }
    let(:duplicate_intake_1) { create :intake, intake_ticket_id: 1 }
    let(:duplicate_intake_2) { create :intake }
    let(:fake_ticket_1) { double(ZendeskAPI::Ticket, id: 1) }

    before do
      allow(subject).to receive(:current_intake).and_return(intake)
      allow(DuplicateIntakeGuard).to receive(:new).with(intake).and_return duplicate_intake_guard_spy
      allow(duplicate_intake_guard_spy).to receive(:get_duplicates).and_return([duplicate_intake_1, duplicate_intake_2])
      allow(Zendesk::TicketIdentifyingService).to receive(:new).and_return(fake_identifying_service)
      allow(fake_identifying_service).to receive(:find_primary_ticket).with([1]).and_return(fake_ticket_1)
    end

    it "creates client efforts for all duplicate intakes" do
      expect {
        get :edit
      }.to change(ClientEffort, :count).by(1)

      client_effort = ClientEffort.last
      expect(client_effort.effort_type).to eq "returned_to_intake"
      expect(client_effort.intake).to eq duplicate_intake_1
      expect(client_effort.ticket_id).to eq duplicate_intake_1.intake_ticket_id
      expect(client_effort.made_at).to be_within(1.second).of(Time.now)
    end
  end
end
