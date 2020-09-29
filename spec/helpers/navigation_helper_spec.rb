require "rails_helper"

RSpec.describe NavigationHelper do
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
        controller.request.path = "/users/profile"
      end

      it "returns a tab link with is-selected" do
        link = helper.tab_navigation_link("Tab that is selected", user_profile_path(locale: "en"))

        link_html = Nokogiri::HTML.fragment(link).at_css("a")

        expect(link_html).to have_text "Tab that is selected"
        expect(link_html["class"]).to eq "tab-bar__tab is-selected"
        expect(link_html["href"]).to eq user_profile_path(locale: "en")
      end
    end
  end
end