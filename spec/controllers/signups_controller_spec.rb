require "rails_helper"

RSpec.describe SignupsController do
  describe "#create" do
    context "with valid params" do
      before do
        allow(subject).to receive(:send_mixpanel_event)
      end

      let(:params) { {signup: {name: "Gary Guava", zip_code: "94110", email_address: "example@example.com", phone_number: "415-555-1212"}} }

      it "creates a signup" do
        expect {
          post :create, params: params
        }.to change(Signup, :count).by(1)
        signup = Signup.last
        expect(signup.name).to eq("Gary Guava")
        expect(signup.zip_code).to eq("94110")
        expect(signup.email_address).to eq("example@example.com")
        expect(signup.phone_number).to eq("+14155551212")
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq("Thank you! You will receive a notification when we open in January 2021.")
      end

      it "sends an event to mixpanel" do
        post :create, params: params
        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "2021-sign-up")
      end
    end

    context "invalid params" do
      render_views

      let(:params) { { signup: { name: "Gary Guava", zip_code: "94110" } } }
      before do
        allow(subject).to receive(:send_mixpanel_validation_error)
      end

      it "shows validation errors" do
        expect {
          post :create, params: params
        }.not_to change(Signup, :count)

        expect(response).to render_template(:new)
        expect(response.body).to include("Please choose some way for us to contact you.")
        expect(subject).to have_received(:send_mixpanel_validation_error)
      end
    end
  end

  describe "#new" do
    it "passes an empty signup to the template" do
      get :new

      expect(assigns(:signup)).to be_kind_of Signup
    end
  end
end
