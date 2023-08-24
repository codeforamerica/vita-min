require "rails_helper"

RSpec.feature "Configure experiments in the hub", js: true do
  context "As an authenticated user" do
    let(:logged_in_user) { create :admin_user }
    let(:experiment) { Experiment.last }
    let!(:current_organization) { create :organization, name: "Orange Organization", experiments: [experiment] }
    let!(:new_organization) { create :organization, name: "Apple Organization" }

    before do
      login_as logged_in_user
      experiment.update(enabled: true)
    end

    scenario "logged in admin user can edit the list of vita partners that are opted into an experiment" do
      visit edit_hub_admin_experiment_path(id: experiment.id)

      expect(page).to have_text "Orange Organization"

      select "true", from: "enabled"
      fill_in_tagify '.multi-select-vita-partner', "Apple Organization"

      click_on "Save"

      expect(table_contents(page.find('.experiments-table'))).to include(hash_including({"name" => experiment.name, "enabled" => "true", "participating VITA partners" => "2"}))
    end
  end
end
