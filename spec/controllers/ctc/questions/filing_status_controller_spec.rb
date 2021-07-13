require 'rails_helper'

describe Ctc::Questions::FilingStatusController do
  let!(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe '#update' do
    context "with no answer" do
      let(:params) do
        {}
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors).not_to be_blank
        expect(intake.filing_joint).to eq nil
      end
    end
  end
end