require "rails_helper"

RSpec.describe Questions::SpouseConsentController do
  let(:filing_joint) { "yes" }
  let(:intake) { create :intake, filing_joint: filing_joint }
  let!(:user) { create :user, intake: intake, first_name: "Barry" }
  let!(:spouse_user) { create :spouse_user, intake: intake, first_name: "Benny" }

  before do
    allow(subject).to receive(:current_user).and_return(user)
  end

  describe ".show?" do
    context "when they are filing joint" do
      let(:filing_joint) { "yes" }
      it "returns true" do
        expect(Questions::SpouseConsentController.show?(intake)).to eq true
      end
    end

    context "when they are not filing joint" do
      let(:filing_joint) { "no" }
      it "returns false" do
        expect(Questions::SpouseConsentController.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    render_views

    it "includes the name of the spouse" do
      get :edit

      expect(response.body).to include(spouse_user.full_name)
    end
  end

  describe "#update" do
    context "with valid params" do
      let (:params) do
        {
          spouse_consent_form: {
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

        spouse_user.reload
        expect(spouse_user.consented_to_service).to eq "yes"
        expect(spouse_user.consented_to_service_ip).to eq ip_address
        expect(spouse_user.consented_to_service_at).to eq current_time
      end
    end

    context "with invalid params" do
      let (:params) do
        {
          spouse_consent_form: {
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