require "rails_helper"

RSpec.describe OmniAuth::Strategies::IdMe do
  let(:access_token) { instance_double('AccessToken', :options => {}) }
  let(:parsed_response) { instance_double('ParsedResponse') }
  let(:response) { instance_double('Response', :parsed => parsed_response) }

  subject do
    OmniAuth::Strategies::IdMe.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  context "client options" do
    context "in production" do
      before { allow(Rails).to receive(:env).and_return("production".inquiry) }

      xit "should use the production domain" do
        # I can't yet figure out how to test this. The class seems to be loaded before the env method is stubbed
        expect(subject.options.client_options.site).to eq("https://api.id.me")
        expect(subject.options.client_options.authorize_url).to eq("https://api.id.me/oauth/authorize")
        expect(subject.options.client_options.token_url).to eq("https://api.id.me/oauth/token")
      end
    end

    context "in development" do
      before { allow(Rails).to receive(:env).and_return "development".inquiry }
      it "should use the sandbox domain" do
        expect(subject.options.client_options.site).to eq("https://api.idmelabs.com")
        expect(subject.options.client_options.authorize_url).to eq("https://api.idmelabs.com/oauth/authorize")
        expect(subject.options.client_options.token_url).to eq("https://api.idmelabs.com/oauth/token")
      end
    end

    context "in test" do
      before { allow(Rails).to receive(:env).and_return "test".inquiry }
      it "should use the sandbox domain" do
        expect(subject.options.client_options.site).to eq("https://api.idmelabs.com")
        expect(subject.options.client_options.authorize_url).to eq("https://api.idmelabs.com/oauth/authorize")
        expect(subject.options.client_options.token_url).to eq("https://api.idmelabs.com/oauth/token")
      end
    end
  end

  describe ".raw_info" do
    it "should use relative paths" do
      expect(access_token).to receive(:get).with("api/public/v3/attributes.json").and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end
  end

  context "with valid json response from id.me" do
    let(:parsed_response) do
      {
        "attributes" => [
          {
            "handle" => "fname",
            "name" => "First Name",
            "value" => "Santina"
          },
          {
            "handle" => "lname",
            "name" => "Last Name",
            "value" => "Walter"
          },
          {
            "handle" => "social",
            "name" => "Full SSN",
            "value" => "222334444"
          },
          {
            "handle" => "phone",
            "name" => "Phone",
            "value" => "1554442233"
          },
          {
            "handle" => "email",
            "name" => "Email",
            "value" => "santina.walter@id.me"
          },
          {
            "handle" => "uuid",
            "name" => "Unique Identifier",
            "value" => "d733a89e2e634f04ac2fe66c97f71612"
          },
          {
            "handle" => "zip",
            "name" => "Zip Code",
            "value" => "20982-5194"
          },
          {
            "handle" => "age",
            "name" => "Age",
            "value" => 26
          },
          {
            "handle" => "birth_date",
            "name" => "Birth Date",
            "value" => "1993-09-06"
          },
          {
            "handle" => "street",
            "name" => "Street",
            "value" => "46125 Etsuko Lights"
          },
          {
            "handle" => "city",
            "name" => "City",
            "value" => "New Geraldinefurt"
          },
          {
            "handle" => "state",
            "name" => "State",
            "value" => "Nevada"
          }
        ],
        "status" => [
          {
            "group" => "identity",
            "subgroups" => [
              "IAL2"
            ],
            "verified" => true
          }
        ]
      }
    end

    before do
      allow(subject).to receive(:raw_info).and_return(parsed_response)
    end

    context "#info" do
      it "should set name, email, first_name, last_name, birth_date, age, location, address, and status information" do
        expect(subject.info[:first_name]).to eq "Santina"
        expect(subject.info[:last_name]).to eq "Walter"
        expect(subject.info[:name]).to eq "Santina Walter"
        expect(subject.info[:phone]).to eq "1554442233"
        expect(subject.info[:social]).to eq "222334444"
        expect(subject.info[:email]).to eq "santina.walter@id.me"
        expect(subject.info[:birth_date]).to eq "1993-09-06"
        expect(subject.info[:age]).to eq 26
        expect(subject.info[:location]).to eq "New Geraldinefurt, Nevada"
        expect(subject.info[:street]).to eq "46125 Etsuko Lights"
        expect(subject.info[:city]).to eq "New Geraldinefurt"
        expect(subject.info[:state]).to eq "Nevada"
        expect(subject.info[:zip_code]).to eq "20982-5194"
        expect(subject.info[:group]).to eq "identity"
        expect(subject.info[:subgroups]).to eq ["IAL2"]
        expect(subject.info[:verified]).to eq true
      end
    end

    context "#uid" do
      it "should return the uuid from the id.me json" do
        expect(subject.uid).to eq "d733a89e2e634f04ac2fe66c97f71612"
      end
    end

    context "#extra" do
      it "should return the parsed json response as raw_info" do
        expect(subject.extra).to eq({ raw_info: parsed_response })
      end
    end
  end
end
