require "rails_helper"

RSpec.describe RedirectsController, type: :controller do
  describe "GET #outreach" do
    it "redirects to the outreach URL" do
      get :outreach

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("https://www.getyourrefund.org/?utm_source=gyr&utm_medium=sms&utm_campaign=w1")
    end
  end
end
