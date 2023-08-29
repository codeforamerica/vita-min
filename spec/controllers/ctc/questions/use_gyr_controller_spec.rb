require "rails_helper"

describe Ctc::Questions::UseGyrController do
  describe "#edit" do
    context 'with an intake in the session' do
      let(:client) { create :client_with_ctc_intake_and_return}
      let(:intake) { client.intake }

      before do
        session[:intake_id] = intake.id
      end

      it "renders edit template" do
        get :edit, params: {}
        expect(response).to render_template :edit
      end
    end

    context 'without an intake in the session' do
      it "redirects to the ctc homepage" do
        get :edit, params: {}
        expect(response).to redirect_to(question_path(id: Navigation::CtcQuestionNavigation.first))
      end
    end
  end
end