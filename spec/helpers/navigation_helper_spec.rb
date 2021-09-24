require "rails_helper"

RSpec.describe NavigationHelper do
  describe "#fraud_icon" do
    let(:client) { create(:client_with_ctc_intake_and_return)}

    context "the client with fraud suspected" do
      before do
        allow_any_instance_of(FraudIndicatorService).to receive(:fraud_suspected?).and_return(true)
      end

      it "returns the fraud icon" do
        expect(helper.fraud_icon(client)).to include("assets/security-notification")
      end
    end

    context "client with no fraud suspected" do
      it "returns nil" do
        expect(helper.fraud_icon(client)).to be_nil
      end
    end
  end

  describe "#selected_if_path_matches" do
    context "with a path that matches the current path" do
      before do
        controller.request.path = "/matching/path"
      end

      it "returns a tab link with is-selected" do
        link = helper.tab_navigation_link("Tab that is selected", "/matching/path")

        link_html = Nokogiri::HTML.fragment(link).at_css("a")

        expect(link_html).to have_text "Tab that is selected"
        expect(link_html["href"]).to eq "/matching/path"
        expect(link_html["class"]).to eq "tab-bar__tab is-selected"
      end
    end

    context "with a path that does not match the current path" do
      before do
        controller.request.path = "/not/matching/path"
      end

      it "returns a tab link without is-selected" do
        link = helper.tab_navigation_link("Tab that is not selected", "/not/selected/path")

        link_html = Nokogiri::HTML.fragment(link).at_css("a")

        expect(link_html).to have_text "Tab that is not selected"
        expect(link_html["href"]).to eq "/not/selected/path"
        expect(link_html["class"]).to eq "tab-bar__tab"
      end
    end

    context "without locale in the current path but otherwise matching" do
      before do
        controller.request.path = "/hub/profile"
      end

      it "returns a tab link with is-selected" do
        link = helper.tab_navigation_link("Tab that is selected", hub_user_profile_path(locale: "en"))

        link_html = Nokogiri::HTML.fragment(link).at_css("a")

        expect(link_html).to have_text "Tab that is selected"
        expect(link_html["class"]).to eq "tab-bar__tab is-selected"
        expect(link_html["href"]).to eq hub_user_profile_path(locale: "en")
      end
    end

    context "when the navigation link includes an anchor fragment but the request does not" do
      before do
        controller.request.path = "/hub/profile"
      end

      it "returns a tab link with is-selected" do
        link = helper.tab_navigation_link("Tab that is selected", hub_user_profile_path(locale: "en", anchor: "section"))

        link_html = Nokogiri::HTML.fragment(link).at_css("a")

        expect(link_html).to have_text "Tab that is selected"
        expect(link_html["class"]).to eq "tab-bar__tab is-selected"
        expect(link_html["href"]).to eq hub_user_profile_path(locale: "en", anchor: "section")
      end
    end
  end
end