require "rails_helper"

RSpec.feature "Adjust state routing", :js do
  context "As an authenticated admin" do
    let(:user) { create :admin_user }
    let(:orange_organization) { create(:organization, name: "Orange Organization", coalition: nil) }
    let(:crocodile_conglomerate) { create(:coalition, name: "Crocodile Conglomerate") }
    let(:squid_association) { create(:organization, name: "Squid Association", coalition: crocodile_conglomerate) }
    let(:tadpole_division) { create(:site, name: "Tadpole Division", parent_organization: squid_association) }

    let(:orange_state_target) { create(:state_routing_target, state_abbreviation: "FL", target: orange_organization) }
    let!(:orange_fraction) { create(:state_routing_fraction, state_routing_target: orange_state_target, vita_partner: orange_organization, routing_fraction: 0.6) }

    let(:crocodile_state_target) { create(:state_routing_target, state_abbreviation: "FL", target: crocodile_conglomerate) }
    let!(:tadpole_fraction) { create(:state_routing_fraction, state_routing_target: crocodile_state_target, vita_partner: tadpole_division, routing_fraction: 0.4) }

    before do
      login_as user
    end

    scenario "examining and changing state routing" do
      visit hub_state_routings_path
      click_on "Florida"

      orange_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{orange_organization.id}][routing_percentage]"
      tadpole_routing_percentage_field = "hub_state_routing_form[state_routing_fraction_attributes][#{tadpole_division.id}][routing_percentage]"

      within "#state-routing-org-#{orange_organization.id}" do
        expect(page).to have_text "Orange Organization"
        expect(find_field(orange_routing_percentage_field).value).to eq "60"
      end

      # make tadpole site visible
      within "#state-routing-org-#{squid_association.id}" do
        find(".state-routing-accordion__button").click
      end

      within "#state-routing-site-#{tadpole_division.id}" do
        expect(page).to have_text "Tadpole Division"
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
