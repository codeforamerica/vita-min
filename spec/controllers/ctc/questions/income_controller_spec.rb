require "rails_helper"

describe Ctc::Questions::IncomeController, requires_default_vita_partners: true do
  describe '#update' do
    it_behaves_like :first_page_of_ctc_intake_update, form_name: :ctc_income_form

    context "with a valid form" do
      let(:had_reportable_income) { "no" }
      let(:params) do
        {
          ctc_income_form: {
            had_reportable_income: had_reportable_income,
          }
        }
      end

      before do
        allow(MixpanelService).to receive(:send_event)
        allow_any_instance_of(Ctc::IncomeForm).to receive(:valid?).and_return true
        allow_any_instance_of(Ctc::IncomeForm).to receive(:save).and_return true
      end

      it "sends an event to mixpanel" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
                                                                     event_name: "question_answered",
                                                                     data: { had_reportable_income: "no" }
                                                                   ))
      end

      context "when answer is yes" do
        let(:had_reportable_income) { "yes" }

        it "redirects out of the flow" do
          post :update, params: params
          expect(response).to redirect_to questions_use_gyr_path
        end
      end

      context "when the answer is no" do
        let(:had_reportable_income) { "no" }

        it "redirects to the next page in the flow" do
          post :update, params: params
          expect(response).to redirect_to questions_file_full_return_path
        end
      end
    end
  end
end
