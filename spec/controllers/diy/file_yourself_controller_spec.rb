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
        let(:existing_diy_intake) { create :diy_intake, source: "existing_source", referrer: "existing_referrer", locale: "en", visitor_id: "existing_visitor_id" }
        let(:file_yourself_form_double) { instance_double(FileYourselfForm) }
        before do
          session[:diy_intake_id] = existing_diy_intake.id
          allow(FileYourselfForm).to receive(:new).and_return file_yourself_form_double
          allow(file_yourself_form_double).to receive(:save)
        end

        it "updates the intake from the session except source, referrer, etc" do
          expect do
            post :update, params: params
          end.not_to change(DiyIntake, :count)

          expect(FileYourselfForm).to have_received(:new).with(existing_diy_intake, params: hash_including(params))
          expect(file_yourself_form_double).to have_received(:save)

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
