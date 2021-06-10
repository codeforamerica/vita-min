require "rails_helper"

RSpec.feature "Visit ctc landing page" do
  scenario "has ctc header and footer" do
    visit_subdomain "ctc", "/"
    within(".main-header") do
      expect(page).to have_link("GetCTC", href: ctc_root_path)
    end
  end
end
