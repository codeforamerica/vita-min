require "rails_helper"

describe TaxReturnService do
  describe ".handle_status_change" do
    let(:client) { create :client }
    let!(:intake) do
      create(
        :intake,
        client: client,
        locale: "es",
        email_address: "client@example.com",
        spouse_email_address: "spouse@example.com",
        sms_phone_number: "+15005550006"
      )
    end
    let(:user) { create :user }
    let(:tax_return) { create :tax_return, client: client, year: 2019 }
    let(:form_params) {
      { tax_return_id: tax_return.id }
    }
    let(:form) { Hub::TakeActionForm.new(client, user, form_params) }

    context "there is an outgoing message body" do
      let(:form_params) {
        { tax_return_id: tax_return.id, message_body: "message body" }
      }
      context "there is a email contact method" do
        it "sends an email" do
          expect {
            TaxReturnService.handle_status_change(form)
          }.to change(OutgoingEmail, :count).by(1)
        end
      end
    end

    context "there isn't an outgoing message body" do
      it "does not send an email" do
        expect {
          TaxReturnService.handle_status_change(form)
        }.not_to change(OutgoingEmail, :count)
      end
    end
  end
end