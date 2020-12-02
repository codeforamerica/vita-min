require "rails_helper"
require "spec_helper"
require "rack/test"

class DummyController < ApplicationController
  def create; end
end

begin
  _routes = Rails.application.routes
  _routes.disable_clear_and_finalize = true
  _routes.clear!
  Rails.application.routes_reloader.paths.each { |path| load(path) }
  _routes.draw do
    post '/dummy' => 'dummy#create'
  end
  ActiveSupport.on_load(:action_controller) { _routes.finalize! }
ensure
  _routes.disable_clear_and_finalize = false
end

describe ValidateRequestParams do
  include Rack::Test::Methods

  let(:app) { VitaMin::Application }

  context "with invalid characters" do
    let(:null_byte) { "\u0000" }

    it "responds with 400 BadRequest for strings" do
      post "/dummy", name: "I am #{null_byte} bad"

      expect(last_response.bad_request?).to eq true
    end

    it "responds with 400 BadRequest for hashes with strings" do
      post "/dummy", name: { inner_key: "I am #{null_byte} bad" }

      expect(last_response.bad_request?).to eq true
    end

    it "responds with 400 BadRequest for arrays with strings" do
      post "/dummy", name: ["I am #{null_byte} bad"]

      expect(last_response.bad_request?).to eq true
    end

    it "responds with 400 BadRequest for arrays containing hashes with string values" do
      post "/dummy", name: [
        {
          inner_key: "I am #{null_byte} bad"
        }
      ]

      expect(last_response.bad_request?).to eq true
    end
  end

  context "without invalid characters" do
    it "responds with a 204 no content" do
      post "/dummy"

      expect(last_response.no_content?).to eq true
    end

    it "responds with a 204 no content for strings" do
      post "/dummy", name: "safe name"

      expect(last_response.no_content?).to eq true
    end

    it "responds with a 204 no content for hashes with strings" do
      post "/dummy", name: { inner_key: "safe name" }

      expect(last_response.no_content?).to eq true
    end

    it "responds with a 204 no content for arrays with strings" do
      post "/dummy", name: ["safe name"]

      expect(last_response.no_content?).to eq true
    end

    it "responds with a 204 no content for arrays containing hashes with string values" do
      post "/dummy", name: [{ inner_key: "safe name" }]

      expect(last_response.no_content?).to eq true
    end
  end

  context "with invalid characters in my_session cookie" do
    let(:null_byte) { "%00" }

    it "responds with 400 BadRequest" do
      set_cookie "my_session=adfec7as9413db963b5#{null_byte}"

      get "/login"

      expect(last_response.bad_request?).to eq true
    end
  end

  context "WITH valid characters in my_session cookie" do
    it "responds with a 200 ok" do
      set_cookie "my_session=adfec7as9413db963b5"

      get "/login"

      expect(last_response.ok?).to eq true
    end
  end
end