require "rails_helper"

RSpec.describe Diy::FileYourselfController do
  describe "#edit" do
    before do
      allow(controller).to receive(:open_for_diy?).and_return(open_for_diy)
    end

    context "when app if open for DIY" do
      let(:open_for_diy) { true }

      it "is 200 OK 👍" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "when app is closed for DIY" do
      let(:open_for_diy) { false }

      it "redirects to the root path" do
        get :edit

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          file_yourself_form: {
            email_address: "example@example.com",
            preferred_first_name: "Robot",
            filing_frequency: "some_years",
          }
        }
      end
      before do
        session[:source] = "beep"
        session[:referrer] = "boop"
        allow(subject).to receive(:visitor_id).and_return "blop"
      end

      context "without a diy intake in the session" do
        it "creates a new diy intake and stores the id in the session" do
          expect do
            post :update, params: params
          end.to change(DiyIntake, :count).by(1)

          diy_intake = DiyIntake.last
          expect(session[:diy_intake_id]).to eq diy_intake.id

          expect(diy_intake.source).to eq "beep"
          expect(diy_intake.referrer).to eq "boop"
          expect(diy_intake.visitor_id).to eq "blop"
          expect(diy_intake.locale).to eq "en"
        end
      end

      context "with a diy intake in the session" do
        let(:existing_diy_intake) { create :diy_intake, :filled_out, source: "existing_source", referrer: "existing_referrer", locale: "en", visitor_id: "existing_visitor_id" }
        before do
          session[:diy_intake_id] = existing_diy_intake.id
        end

        it "updates the intake from the session except source, referrer, etc" do
          expect do
            post :update, params: params
          end.not_to change(DiyIntake, :count)

          existing_diy_intake.reload
          expect(existing_diy_intake.email_address).to eq "example@example.com"
          expect(existing_diy_intake.preferred_first_name).to eq "Robot"
          expect(existing_diy_intake.filing_frequency).to eq "some_years"

          expect(existing_diy_intake.source).to eq "existing_source"
          expect(existing_diy_intake.referrer).to eq "existing_referrer"
          expect(existing_diy_intake.visitor_id).to eq "existing_visitor_id"
          expect(existing_diy_intake.locale).to eq "en"
        end
      end

      it "redirects to the tax slayer link page" do
        post :update, params: params

        expect(response).to redirect_to diy_continue_to_fsa_path
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          file_yourself_form: {
            email_address: nil,
            preferred_first_name: "Robot",
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

  describe "redirects", type: :request do
    it "redirects from /diy to this page's main URL" do
      get "/en/diy"
      expect(response).to redirect_to Diy::FileYourselfController.to_path_helper
    end

    it "redirects from /diy/email to this page's main URL" do
      get "/en/diy/email"
      expect(response).to redirect_to Diy::FileYourselfController.to_path_helper
    end
  end
end
