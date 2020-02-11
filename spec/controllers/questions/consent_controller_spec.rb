require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:intake) { create :intake }
  let(:user) { create :user, intake: intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "with valid params" do
      let (:params) do
        {
          consent_form: {
            consented_to_service: "yes"
          }
        }
      end
      let(:current_time) { Date.new(2020, 4, 15) }
      let(:ip_address) { "127.0.0.1" }

      before do
        request.remote_ip = ip_address
        allow(DateTime).to receive(:current).and_return current_time
      end

      it "saves the answer, along with a timestamp and ip address" do
        post :update, params: params

        user.reload
        expect(user.consented_to_service).to eq "yes"
        expect(user.consented_to_service_ip).to eq ip_address
        expect(user.consented_to_service_at).to eq current_time
      end
    end

    context "with invalid params" do
      let (:params) do
        {
          consent_form: {
            consented_to_service: "no"
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:consented_to_service].first).to eq "We need your consent to continue."
      end
    end
  end
end