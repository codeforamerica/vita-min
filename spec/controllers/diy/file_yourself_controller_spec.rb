require "rails_helper"

# TODO: move some of these expectations over to the form spec
RSpec.describe Diy::FileYourselfController do
  describe "#edit" do
    it "is 200 OK 👍" do
      get :edit

      expect(response).to be_ok
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          diy_intake: {
            email_address: "example@example.com",
            preferred_first_name: "Robot",
            received_1099: "yes",
            filing_frequency: "some_years",
          }
        }
      end
      before do
        session[:source] = "beep"
        session[:referrer] = "boop"
        allow(subject).to receive(:visitor_id).and_return "blop"
      end

      it "creates a new diy intake and stores the id in the session" do
        expect do
          post :update, params: params
        end.to change(DiyIntake, :count).by(1)

        diy_intake = DiyIntake.last
        expect(session[:diy_intake_id]).to eq diy_intake.id
        expect(diy_intake.email_address).to eq "example@example.com"
        expect(diy_intake.preferred_first_name).to eq "Robot"
        expect(diy_intake.received_1099).to eq "yes"
        expect(diy_intake.filing_frequency).to eq "some_years"

        expect(diy_intake.source).to eq "beep"
        expect(diy_intake.referrer).to eq "boop"
        expect(diy_intake.visitor_id).to eq "blop"
        expect(diy_intake.locale).to eq "en"
      end

      it "redirects to the tax slayer link page" do
        post :update, params: params

        expect(response).to redirect_to diy_continue_to_fsa_path
      end
    end

    context "without invalid params" do
      let(:invalid_params) do
          {
            diy_intake: {
              email_address: nil,
              preferred_first_name: "Robot",
              received_1099: "yes",
              filing_frequency: "some_years",
            }
          }
      end

      it "returns 200 and doesn't make a diy intake record" do
        expect do
          post :update, params: invalid_params
        end.not_to change(DiyIntake, :count)

        expect(response).to render_template :edit
      end
    end
  end
end
