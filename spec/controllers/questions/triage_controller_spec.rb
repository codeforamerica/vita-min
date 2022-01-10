require "rails_helper"

RSpec.describe Questions::TriageController do
  controller do
    def edit
      render plain: 'ok'
    end

    def form_class
      Class.new(Form)
    end
  end

  before do
    routes.draw { get "edit" => "questions/triage#edit" }
  end

  context "#edit" do
    context "when a triage is in the session" do
      before do
        session[:triage_id] = create(:triage).id
      end

      it "shows the sign-in link" do
        get :edit
        expect(assigns[:show_client_sign_in_link]).to be_truthy
      end
    end

    context "when a triage is not in the session" do
      it "redirects to the first triage page" do
        get :edit
        expect(response).to(redirect_to(Questions::TriageIncomeLevelController.to_path_helper))
      end
    end
  end
end
