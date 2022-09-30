require "rails_helper"

RSpec.describe "GYR offseason redirects", type: :request do
  describe "questions pages when not logged-in" do
    it_behaves_like :when_intake_is_open_render_normally, GyrQuestionNavigation.first
    it_behaves_like :when_intake_is_closed_redirect_to_home, GyrQuestionNavigation.first
  end

  describe "questions pages when logged-in" do
    before do
      login_as(create(:client), scope: :client)
    end

    it_behaves_like :when_intake_is_open_render_normally, GyrQuestionNavigation.first
    it_behaves_like :when_intake_is_closed_render_normally, GyrQuestionNavigation.first
  end

  describe "login pages" do
    it_behaves_like :when_intake_is_open_render_normally, Portal::ClientLoginsController, action: :new
    it_behaves_like :when_intake_is_closed_render_normally, Portal::ClientLoginsController, action: :new
  end

  describe "diy pages" do
    it_behaves_like :when_intake_is_open_render_normally, Diy::FileYourselfController
    it_behaves_like :when_intake_is_closed_render_normally, Diy::FileYourselfController
  end
end
