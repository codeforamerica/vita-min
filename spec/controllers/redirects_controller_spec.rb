require "rails_helper"

RSpec.describe RedirectsController, type: :controller do
  describe "GET #outreach" do

    it "redirects to the outreach URL" do
      get :outreach, params: { locale: nil }

      expect(response).to redirect_to(
                            "http://test.host/?utm_campaign=w1&utm_medium=sms&utm_source=gyr"
                          )
    end

    context "when locale is english" do
      it "redirects to the english outreach URL" do
        get :outreach, params: { locale: :en }

        expect(response).to redirect_to(
                              "http://test.host/en?utm_campaign=w1&utm_medium=sms&utm_source=gyr"
                            )
      end
    end

    context "when locale is spanish" do
      it "redirects to the spanish outreach URL" do
        get :outreach, params: { locale: :es }

        expect(response).to redirect_to(
                              "http://test.host/es?utm_campaign=w1&utm_medium=sms&utm_source=gyr"
                            )
      end
    end

    it "returns a 302 status" do
      get :outreach

      expect(response).to have_http_status(:found)
    end
  end
end
