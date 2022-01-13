require "rails_helper"

RSpec.feature "Adjust state routing", :js do
  context "As an authenticated admin" do
    let(:user) { create :admin_user }
    let(:orange_organization) { create(:organization, name: "Orange Organization", coalition: nil) }
    let(:crocodile_conglomerate) { create(:coalition, name: "Crocodile Conglomerate") }
    let(:squid_association) { create(:organization, name: "Squid Association", coalition: crocodile_conglomerate) }
    let(:tadpole_division) { create(:site, name: "Tadpole Division", parent_organization: squid_association) }

    let(:orange_state_target) { create(:state_routing_target, state_abbreviation: "FL", target: orange_organization) }
    let!(:orange_fraction) { create(:state_routing_fraction, state_routing_target: orange_state_target, vita_partner: orange_organization, routing_fraction: 0.6, org_level_routing_enabled: true) }

    let(:crocodile_state_target) { create(:state_routing_target, state_abbreviation: "FL", target: crocodile_conglomerate) }
    let!(:squid_fraction) { create(:state_routing_fraction, state_routing_target: crocodile_state_target, vita_partner: squid_association, routing_fraction: 0.4, org_level_routing_enabled: true) }
    let!(:tadpole_fraction) { create(:state_routing_fraction, state_routing_target: crocodile_state_target, vita_partner: tadpole_division, routing_fraction: 0.0) }

    before do
      login_as user
    end

    scenario "examining and changing state routing" do
      visit hub_state_routings_path
      click_on "Florida"

      orange_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{orange_organization.id}][routing_percentage]"
      squid_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{squid_association.id}][routing_percentage]"
      tadpole_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{tadpole_division.id}][routing_percentage]"

      within "#state-routing-org-#{orange_organization.id}" do
        expect(page).to have_text "Orange Organization"
        expect(find_field(orange_routing_percentage_field).value).to eq "60"
      end

      within "#state-routing-org-#{squid_association.id}" do
        # make tadpole site visible
        find(".state-routing-accordion__button").click

        expect(page).to have_text "Squid Association"
        expect(page).to have_field("toggle-org-level-routing", visible: false, checked: true)
        expect(find_field(squid_routing_percentage_field).value).to eq "40"

        # the click on the input field is intercepted by the slider span, so click the span
        find(".slider").click
        expect(page).to have_field("toggle-org-level-routing", visible: false, checked: false)
        expect(find_field(squid_routing_percentage_field, disabled: true).value).to eq "0"
      end

      within "#state-routing-site-#{tadpole_division.id}" do
        expect(find_field(tadpole_routing_percentage_field).value).to eq "0"
        expect(page).to have_text "Tadpole Division"
        fill_in tadpole_routing_percentage_field, with: 40
        expect(find_field(tadpole_routing_percentage_field).value).to eq "40"
      end

      fill_in orange_routing_percentage_field, with: 10
      fill_in tadpole_routing_percentage_field, with: 90

      click_on "Save"

      tadpole_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{tadpole_division.id}][routing_percentage]"
      orange_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{orange_organization.id}][routing_percentage]"

      # make tadpole site visible
      within "#state-routing-org-#{squid_association.id}" do
        find(".state-routing-accordion__button").click
      end

      expect(find_field(tadpole_routing_percentage_field).value).to eq "90"
      expect(find_field(orange_routing_percentage_field).value).to eq "10"
    end
  end
end
