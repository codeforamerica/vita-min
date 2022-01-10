require "rails_helper"

RSpec.describe Questions::TriageController do
  controller do
    def edit; render plain: 'ok'; end

    def form_class
      Class.new(Form)
    end
  end

  before do
    routes.draw { get "edit" => "questions/triage#edit" }
  end

  context "#edit" do
    it "shows the sign-in link" do
      get :edit
      expect(assigns[:show_client_sign_in_link]).to be_truthy
    end
  end
end
