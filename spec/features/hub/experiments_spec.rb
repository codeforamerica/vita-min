require "rails_helper"

RSpec.feature "Configure experiments in the hub", js: true do
  context "As an authenticated user" do
    let(:logged_in_user) { create :admin_user }
    let(:experiment) { create :experiment, name: "Experiment A", enabled: false }
    let!(:organization) { create :organization, name: "Apple Organization" }

    before do
      login_as logged_in_user
      stub_const("ExperimentService::CONFIG", {
        experiment.key => {
          name: "Experiment A",
          treatment_weights: {
            'treatment_x' => 1,
            'treatment_y' => 3
          }
        }
      })
    end

    scenario "logged in admin user can edit the list of vita partners that are opted into an experiment" do
      visit edit_hub_admin_experiment_path(id: experiment.id)

      select "true", from: "enabled"
      fill_in_tagify '.multi-select-vita-partner', "Apple Organization"

      click_on "Save"

      expect(table_contents(page.find('.experiments-table'))).to match_rows([{"name" => experiment.name, "enabled" => "true", "participating VITA partners" => "1"}])
    end
  end
end
