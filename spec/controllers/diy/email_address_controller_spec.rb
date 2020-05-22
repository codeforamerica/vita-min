require "rails_helper"

RSpec.describe Diy::EmailAddressController do
  let(:diy_intake) { create(:diy_intake) }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end
  end


  describe "#update" do
    context "with valid params" do
      let(:email_address) { "indie@pendent.org" }
      let(:params) do
        {
          diy_email_address_form: {
            email_address: email_address,
            email_address_confirmation: email_address,
          }
        }
      end

      it "updates diy intake with the email address of the params" do
        expect {
          post :update, params: params
        }.to change { diy_intake.email_address }.from(nil).to(email_address)
      end

      it "enqueues a job to make a zendesk ticket", active_job: true do
        post :update, params: params
        expect(CreateZendeskDiyIntakeTicketJob).to have_been_enqueued
      end
    end

    context "with invalid params" do
      let(:email_address) { "indie@pendent" }
      let(:params) do
        {
          diy_email_address_form: {
            email_address: email_address,
            email_address_confirmation: email_address,
          }
        }
      end

      it "does not update diy intake with the email address of the params" do
        expect {
          post :update, params: params
        }.not_to change { diy_intake.email_address }.from(nil)
      end

      it "does not enqueue a job to make a zendesk ticket", active_job: true do
        post :update, params: params
        expect(CreateZendeskDiyIntakeTicketJob).not_to have_been_enqueued
      end
    end
  end
end

