require "rails_helper"

describe Rack::Attack, type: :request do
  let(:limit) { 5 }
  let(:ip) { "1.2.3.4" }
  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  context "on a post to a login page" do
    it "throttles excessive requests by IP address" do
      params = {
        portal_request_client_login_form: {
          email_address: "client@example.com",
          sms_phone_number: nil
        }
      }
      fake_time = Time.now

      Timecop.freeze(fake_time) do
        limit.times do
          post "/portal/login", params: params, headers: { REMOTE_ADDR: ip }
        end

        # you can't make more requests within the time limit from this IP
        post "/portal/login", params: params, headers: { REMOTE_ADDR: ip }
        expect(response).to have_http_status(:too_many_requests)

        # you can if you have a different IP
        post "/portal/login", params: params, headers: { REMOTE_ADDR: "2.3.4.5" }
        expect(response).to be_ok
      end

      # when the time limit is up you can make requests from the IP again
      Timecop.freeze(fake_time + 15.second) do
        post "/portal/login", params: params, headers: { REMOTE_ADDR: ip }
        expect(response).to be_ok
      end
    end
  end

  context "on a get to a non-login page" do
    it "does nothing" do
      Timecop.freeze

      limit.times do
        get "/", headers: { REMOTE_ADDR: ip }
      end

      get "/", headers: { REMOTE_ADDR: ip }
      expect(response).to have_http_status(302)
    end
  end
end
