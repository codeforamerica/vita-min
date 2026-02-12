require "rails_helper"

RSpec.describe RedirectsController, type: :controller do
  describe "GET #outreach" do
    it "redirects to the outreach URL" do
      get :outreach

      expect(response).to redirect_to(
                            "http://test.host/en?utm_campaign=w1&utm_medium=sms&utm_source=gyr"
                          )
    end

    it "returns a 302 status" do
      get :outreach

      expect(response).to have_http_status(:found)
    end
  end
end
