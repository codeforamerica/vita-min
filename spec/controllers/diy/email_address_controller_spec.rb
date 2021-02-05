require "rails_helper"

RSpec.describe Diy::EmailAddressController do
  let(:diy_intake) { create(:diy_intake) }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
    allow(Rails.configuration).to receive(:diy_off).and_return false
    Rails.application.reload_routes!
  end

  after do
    allow(Rails.configuration).to receive(:diy_off).and_call_original
    Rails.application.reload_routes!
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end

    it "sets a new visitor_id on the diy intake" do
      get :edit

      expect(diy_intake.visitor_id).to be_present
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
    end
  end
end

