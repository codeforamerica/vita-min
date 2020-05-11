require 'rails_helper'

RSpec.describe TicketStatus, type: :model do
  describe "#status_changed?" do
    let(:ticket_status) {create :ticket_status,
                                intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
                                return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
    }

    it "returns true if the given intake status if different from the model value" do
      expect(ticket_status.status_changed?(
           intake_status: EitcZendeskInstance::INTAKE_STATUS_WAITING_FOR_INFO,
           return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
      )).to be true
    end

    it "returns true if the given return status if different from the model value" do
      expect(ticket_status.status_changed?(
        intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
        return_status: EitcZendeskInstance::RETURN_STATUS_READY_FOR_EFILE
      )).to be true
    end

    it "returns false if the given intake and return status match the model values" do
      expect(ticket_status.status_changed?(
        intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
        return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
      )).to be false
    end
  end
end
