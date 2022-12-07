require "rails_helper"

describe Ctc::Portal::W2s::MiscInfoController do
  let(:intake) { create :ctc_intake, :claiming_eitc, client: create(:client, :with_ctc_return) }
  let(:w2) { create(:w2, intake: intake) }
  let(:params) do
    {
      id: w2.id,
      ctc_w2s_misc_info_form: {
        box12a_code: box12a_code,
        box12a_value: '324',
      }
    }
  end

  before do
    sign_in intake.client
  end

  describe "#next_path" do
    context "the client is qualified for simplified filing" do
      let(:box12a_code) { 'D' }

      it 'returns to the main portal page' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Portal::PortalController.to_path_helper(action: :edit_info))
      end
    end

    context "the client is not qualified for simplified filing" do
      let(:box12a_code) { 'A' }

      it 'redirects to the use gyr page' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::UseGyrController.to_path_helper)
      end
    end
  end
end
