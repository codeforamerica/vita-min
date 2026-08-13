require "rails_helper"

RSpec.describe SimpleFileUrlService do
  subject(:url) do
    described_class.new(
      intake: intake,
      locale: locale,
      source: source
    ).url
  end

  let(:intake) { create :intake, state_of_residence: "CO" }
  let(:locale) { :en }
  let(:source) { "gyrsel" }
  let(:base_url) do
    "https://staging.simplefile.getyourrefund.org"
  end

  before do
    allow(Rails.configuration)
      .to receive(:simple_file_url)
            .and_return(base_url)
  end

  describe "#url" do
    it "builds the Simple File URL" do
      uri = URI.parse(url)

      expect(uri.scheme).to eq("https")
      expect(uri.host).to eq("staging.simplefile.getyourrefund.org")
      expect(uri.path).to eq("/en/service-selection/recommendation/simplefile")
    end

    it "includes the state code and source parameters" do
      query_params = Rack::Utils.parse_query(URI.parse(url).query)

      expect(query_params).to eq("state_code" => "co", "source" => "gyrsel")
    end

    context "when the state is New Jersey" do
      before do
        intake.state_of_residence = "NJ"
      end

      it "uses the New Jersey state code" do
        query_params = Rack::Utils.parse_query(URI.parse(url).query)

        expect(query_params["state_code"]).to eq("nj")
      end
    end

    context "when the locale is Spanish" do
      let(:locale) { :es }

      it "uses the Spanish locale in the path" do
        expect(URI.parse(url).path).to eq("/es/service-selection/recommendation/simplefile")
      end
    end

    context "when the locale is a string" do
      let(:locale) { "es" }

      it "uses the supplied locale" do
        expect(URI.parse(url).path).to start_with("/es/")
      end
    end

    context "when the locale is unsupported" do
      let(:locale) { :fr }

      before do
        allow(I18n).to receive(:default_locale).and_return(:en)
      end

      it "uses the default locale" do
        expect(URI.parse(url).path).to start_with("/en/")
      end
    end

    context "when the source is the homepage" do
      let(:source) { "gyrhomepage" }

      it "includes the homepage source" do
        query_params = Rack::Utils.parse_query(URI.parse(url).query)

        expect(query_params["source"]).to eq("gyrhomepage")
      end
    end

    context "when the source is unsupported" do
      let(:source) { "unsupported" }

      it "omits the source parameter" do
        query_params = Rack::Utils.parse_query(URI.parse(url).query)

        expect(query_params).to eq("state_code" => "co")
      end
    end

    context "when the state is unsupported" do
      before do
        intake.state_of_residence = "NY"
      end

      it "omits the state code parameter" do
        query_params = Rack::Utils.parse_query(URI.parse(url).query)

        expect(query_params).to eq("source" => "gyrsel")
      end
    end

    context "when there is no intake" do
      let(:intake) { nil }
      let(:source) { "gyrhomepage" }

      it "omits the state code parameter" do
        query_params = Rack::Utils.parse_query(URI.parse(url).query)

        expect(query_params).to eq("source" => "gyrhomepage")
      end
    end

    context "when both the state and source are unsupported" do
      let(:source) { "unsupported" }

      before do
        intake.state_of_residence = "NY"
      end

      it "does not add a query string" do
        expect(URI.parse(url).query).to be_nil
      end
    end

    context "when the configured base URL ends with a slash" do
      let(:base_url) do
        "https://staging.simplefile.getyourrefund.org/"
      end

      it "does not add an extra slash to the path" do
        expect(URI.parse(url).path).to eq("/en/service-selection/recommendation/simplefile")
      end
    end

    context "when the Simple File URL is not configured" do
      let(:base_url) { nil }

      it "raises a descriptive error" do
        expect { url }.to raise_error(RuntimeError, "Simple File URL is not configured")
      end
    end

    context "when the Simple File URL is blank" do
      let(:base_url) { "" }

      it "raises a descriptive error" do
        expect { url }.to raise_error(RuntimeError, "Simple File URL is not configured")
      end
    end
  end
end