require "rails_helper"
require "spec_helper"
require "rack/test"

describe ValidateRequestParams, type: :controller do
  include Rack::Test::Methods
  let(:app) { VitaMin::Application }

  class DummyController < ApplicationController
    def create; end
  end

  before(:all) do
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
  end


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

    # there is a limit to how deep the nesting for params go...
    # anything deeper will fall through to the controller and result in a 500 error.
    it "works up to three layers deep" do
      post "/dummy", key: { key: { key: null_byte } }

      expect(last_response.bad_request?).to eq true

      post "/dummy", key: { key: { key: { key: { key: null_byte } } } }

      expect(last_response.bad_request?).to eq false

    end

  end

  context "without invalid characters" do
    it "continues the request" do
      post "/dummy"

      expect(last_response.no_content?).to eq true
    end

    it "continues the request for strings" do
      post "/dummy", name: "safe name"

      expect(last_response.no_content?).to eq true
    end

    it "continues the request for integers" do
      post "/dummy", name: 12

      expect(last_response.no_content?).to eq true
    end

    it "continues the request for booleans" do
      post "/dummy", name: true

      expect(last_response.no_content?).to eq true
    end

    it "continues the request for hashes with strings" do
      post "/dummy", name: { inner_key: "safe name", another_key: "safe name" }

      expect(last_response.no_content?).to eq true
    end

    it "continues the request for safe arrays" do
      post "/dummy", name: ["safe name", "safe_name", true, 12]

      expect(last_response.no_content?).to eq true
    end

    it "continues the request arrays containing hashes with string values" do
      post "/dummy", name: [{ inner_key: "safe name", another_key: "safe name" }]

      expect(last_response.no_content?).to eq true
    end
  end

  context "with invalid characters in _vita_min_session cookie" do
    let(:null_byte) { "%00" }

    it "responds with 400 BadRequest" do
      set_cookie "_vita_min_session=adfec7as9413db963b5#{null_byte}"

      get "/login"

      expect(last_response.bad_request?).to eq true
    end
  end

  context "with valid characters in my_session cookie" do
    it "responds with a 200 ok" do
      set_cookie "_vita_min_session=adfec7as9413db963b5"

      get "/login"

      expect(last_response.ok?).to eq true
    end
  end
end