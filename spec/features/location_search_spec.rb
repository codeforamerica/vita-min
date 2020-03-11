require "rails_helper"

RSpec.feature "Search for VITA locations" do
  context "With nearby VITA locations" do
    before do
      create :vita_provider, :with_coordinates, lat_lon: [37.834519, -122.263273], name: "Chinese Newcomers Service Ctr"
      create :vita_provider, :with_coordinates, lat_lon: [37.831, -122.269738], name: "Chinese Newcomers - VITA"
      create_list :vita_provider, 3, :with_coordinates, lat_lon: [37.826387, -122.269738]
      details = <<~DETAILS.strip
        1234 Main Street
        Oakland, CA 94609
        916-572-0560
        Volunteer Prepared Taxes
      DETAILS
      create :vita_provider, :with_coordinates, lat_lon: [37.82637, -122.269738], name: "Perfect Provider", details: details
    end

    scenario "Click through result pages and view details for one" do
      visit "/vita_providers"

      expect(page).to have_text "Enter your zip code to find providers near you"
      fill_in "Search", with: "94609"

      click_on "Search"

      expect(page).to have_text "We found 6 results within 50 miles of 94609 (Oakland, California)"
      expect(page).to have_text "1. Chinese Newcomers Service Ctr"
      expect(page).to have_text "2. Chinese Newcomers - VITA"

      expect(page).to have_link("Next", href: vita_providers_path(zip: "94609", page: "2", utf8: "✓"))

      click_on "2"

      expect(page).to have_text "6. Perfect Provider"

      click_on "6. Perfect Provider"

      expect(page).to have_selector("h1", text: "Perfect Provider")
      expect(page).to have_selector("a > div", text: "1234 Main Street")
      expect(page).to have_selector("a > div", text: "Oakland, CA 94609")
      expect(page).to have_link("(916) 572-0560")

      click_on "Return to search"

      expect(page).to have_text "6. Perfect Provider"
    end
  end

  context "Without nearby VITA locations" do
    scenario "See an apologetic message" do
      visit "/vita_providers"

      expect(page).to have_text "Enter your zip code to find providers near you"
      fill_in "Search", with: "94609"

      click_on "Search"

      expect(page).to have_selector("h1", text: "We're sorry!")
      expect(page).to have_text "We found no results within 50 miles of 94609 (Oakland, California)."
      expect(page).to have_link "IRS Free File Lookup Tool"
    end
  end
end
