require 'rails_helper'

describe Hub::BulkSignupMessagesController do
  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new

    context "as an admin" do
      before do
        sign_in create(:admin_user)
      end

      context "with valid params" do
        let(:params) { { message_type: "email", signup_selection_id: create(:signup_selection).id } }

        it "sets @message_type" do
          get :new, params: params
          expect(assigns(:message_type)).to eq("email")
        end
      end

      context "with invalid params" do
        it "redirects back to Hub::SignupSelectionsController" do
          get :new
          expect(response).to redirect_to(hub_signup_selections_path)
        end
      end
    end
  end

  describe "#create" do
    it_behaves_like :a_post_action_for_admins_only, action: :create # crashing b/c it needs params

    context "as an admin" do
      before do
        sign_in create(:admin_user)
      end

      context "with valid params" do
        let(:signup_selection) { create(:signup_selection) }
        let(:params) do
          {
            bulk_signup_message:
              { message_type: "email", signup_selection_id: signup_selection.id, message: "We are now open" }
          }
        end

        it "creates and sends the bulk signup message" do
          expect {
            put :create, params: params
          }.to change(BulkSignupMessage, :count).by(1)
          # TODO: .to have_enqueued_job(SendBulkSignupMessageJob).with(BulkSignupMessage)
          # TODO: To redirect somewhere
          record = BulkSignupMessage.last
          expect(record.signup_selection).to eq(signup_selection)
          expect(record.message_type).to eq("email")
          expect(record.message).to eq("We are now open")
        end
      end
    end
  end
end
