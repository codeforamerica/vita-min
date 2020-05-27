require "rails_helper"

RSpec.describe OmniAuth::Strategies::Zendesk do
  let(:parsed_response) { instance_double(ZendeskAPI::User) }
  let(:access_token) { instance_double("Token", token: "zendesk-access-token-here") }

  subject do
    OmniAuth::Strategies::Zendesk.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
    allow_any_instance_of(ZendeskAPI::Client).to receive(:current_user).and_return(parsed_response)
  end

  describe "#token_params" do
    before do
      allow(subject).to receive(:full_host).and_return "http://localhost:3000"
      allow(subject).to receive(:script_name).and_return ""
      allow(subject).to receive(:callback_path).and_return "/users/auth/zendesk/callback"
    end

    it "adds all the necessary params for the token POST" do
      expect(subject.token_params).to eq(
        {
          "client_id" => nil,
          "client_secret" => nil,
          "grant_type" => "authorization_code",
          "redirect_uri" => "http://localhost:3000/users/auth/zendesk/callback",
          "scope" => "read"
        }
      )
    end
  end


  describe "#zendesk_client" do
    it "is a ZendeskAPI::Client configured with the proper token" do
      expect(subject.zendesk_client.config.access_token).to eq("zendesk-access-token-here")
      expect(subject.zendesk_client.config.url).to eq("https://eitc.zendesk.com/api/v2")
    end
  end

  describe "#raw_info" do
    it "calls Zendesk API to get current user" do
      expect(subject.raw_info).to eq(parsed_response)
    end
  end

  context "with User instance from Zendesk Ruby client" do
    let(:parsed_response) do
      ZendeskAPI::User.new(
        nil,
        id: 89178938838417938,
        name: "Tom Tomato",
        email: "ttomato@itsafruit.orange",
        role: ZendeskAPI::Role.new(nil, name: "admin"),
        ticket_restriction: nil,
        two_factor_auth_enabled: true,
        active: true,
        suspended: false,
        verified: true
      )
    end

    before do
      allow(subject).to receive(:raw_info).and_return(parsed_response)
    end

    context "#info" do
      it "should set all the useful fields" do
        expect(subject.info[:id]).to eq 89178938838417938
        expect(subject.info[:name]).to eq "Tom Tomato"
        expect(subject.info[:email]).to eq "ttomato@itsafruit.orange"
        expect(subject.info[:role]).to eq "admin"
        expect(subject.info[:ticket_restriction]).to eq nil
        expect(subject.info[:two_factor_auth_enabled]).to eq true
        expect(subject.info[:active]).to eq true
        expect(subject.info[:suspended]).to eq false
        expect(subject.info[:verified]).to eq true
      end
    end

    context "#uid" do
      it "returns the user's Zendesk ID" do
        expect(subject.uid).to eq 89178938838417938
      end
    end

    context "#extra" do
      it "should return the parsed json response as raw_info" do
        expect(subject.extra).to eq({ raw_info: parsed_response })
      end
    end
  end
end
