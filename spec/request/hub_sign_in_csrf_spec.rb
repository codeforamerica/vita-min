require "rails_helper"

RSpec.describe "hub sign in CSRF protection", type: :request do
  let(:password) { "$user3xample_Password" }
  let!(:user) { create(:user, password: password) }
  let(:credentials) { { user: { email: user.email, password: password } } }

  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  def authenticity_token
    get "/en/hub/sign_in"
    response.body[/name="authenticity_token" value="([^"]+)"/, 1]
  end

  def expect_not_signed_in
    get "/en/hub/sign_in"
    expect(response).to have_http_status(200)
    expect(user.reload.sign_in_count).to eq 0
  end

  context "without an authenticity token" do
    it "does not sign the user in." do
      get "/en/hub/sign_in"
      post "/en/hub/sign_in", params: credentials

      expect(response).to redirect_to("/en/hub/sign_in")
      expect_not_signed_in
    end
  end

  context "with an invalid authenticity token" do
    it "does not sign the user in." do
      get "/en/hub/sign_in"
      post "/en/hub/sign_in", params: credentials.merge(authenticity_token: "invalid")

      expect(response).to redirect_to("/en/hub/sign_in")
      expect_not_signed_in
    end
  end

  context "with a valid authenticity token" do
    it "signs the user in." do
      post "/en/hub/sign_in", params: credentials.merge(authenticity_token: authenticity_token)

      expect(response).to redirect_to("/en/hub/assigned")
      expect(user.reload.sign_in_count).to eq 1
    end
  end

  context "with credentials in the query string" do
    it "rejects the request without signing the user in." do
      token = authenticity_token
      post "/en/hub/sign_in?#{credentials.to_query}", params: { authenticity_token: token }

      expect(response).to have_http_status(400)
      expect_not_signed_in
    end
  end
end
