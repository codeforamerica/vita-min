require "rails_helper"

RSpec.describe ResendDiyConfirmationEmailJob, type: :job do
  let(:fake_zendesk_intake_service) { double(ZendeskDiyIntakeService) }
  let(:diy_intake) { create(:diy_intake) }

  describe "#perform", active_job: true do
    context "without errors" do
      it "appends a comment to the existing ticket" do
        expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
          .and_return(fake_zendesk_intake_service)
        expect(fake_zendesk_intake_service).to receive(:append_resend_confirmation_email_comment)
        described_class.perform_now(diy_intake.id)
      end
    end

    context "with errors" do
      context "when an error is raised while appending the comment" do
        before do
          expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
            .and_return(fake_zendesk_intake_service)
          expect(fake_zendesk_intake_service)
            .to receive(:append_resend_confirmation_email_comment)
            .and_raise(ZendeskServiceHelper::ZendeskServiceError)
        end

        it "raises the error" do
          expect { described_class.perform_now(diy_intake.id) }
            .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
        end
      end
    end
  end
end
