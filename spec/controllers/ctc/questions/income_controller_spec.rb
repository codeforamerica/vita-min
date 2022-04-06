require "rails_helper"

describe Ctc::Questions::IncomeController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::IncomeForm
    end
  end

  describe '#update' do
    context "with a valid form" do
      let(:income_qualifies) { "no" }
      let(:params) do
        {
          ctc_income_form: {
            income_qualifies: income_qualifies,
          }
        }
      end

      it "sends an event to mixpanel" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
                                                                     event_name: "question_answered",
                                                                     data: { income_qualifies: "no" }
                                                                   ))
      end

      context "when answer is no" do
        let(:income_qualifies) { "no" }

        it "redirects out of the flow" do
          post :update, params: params
          expect(response).to redirect_to questions_use_gyr_path
        end
      end

      context "when the answer is yes" do
        let(:income_qualifies) { "yes" }

        it "redirects to the next page in the flow" do
          post :update, params: params
          expect(response).to redirect_to questions_file_full_return_path
        end
      end
    end
  end
end
