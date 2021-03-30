require "rails_helper"

RSpec.feature "Adjust state routing", :js do
  context "As an authenticated admin" do
    let(:user) { create :admin_user }
    let(:orange_organization) { create(:organization, name: "Orange Organization") }
    let(:crocodile_conglomerate) { create(:organization, name: "Crocodile Conglomerate") }
    let!(:coconut_cooperative) { create(:organization, name: "Coconut Cooperative") }
    let!(:orange_vps) { create(:vita_partner_state, state: "FL", vita_partner: orange_organization, routing_fraction: 0.6) }
    let!(:crocodile_vps) { create(:vita_partner_state, state: "FL", vita_partner: crocodile_conglomerate, routing_fraction: 0.4) }

    before do
      login_as user
    end

    scenario "examining and changing state routing" do
      visit hub_state_routings_path
      click_on "Florida"

      orange_routing_percentage_field = "hub_state_routing_form[vita_partner_states_attributes][0][routing_percentage]"
      crocodile_routing_percentage_field = "hub_state_routing_form[vita_partner_states_attributes][1][routing_percentage]"

      within "#vita_partner_state-#{orange_vps.id}" do
        expect(page).to have_text "Orange Organization"
        expect(find_field(orange_routing_percentage_field).value).to eq "60"
      end

      within "#vita_partner_state-#{crocodile_vps.id}" do
        expect(page).to have_text "Crocodile Conglomerate"
        expect(find_field(crocodile_routing_percentage_field).value).to eq "40"
      end

      fill_in orange_routing_percentage_field, with: 0
      fill_in crocodile_routing_percentage_field, with: 90

      click_on "Add routing"
      unpersisted_field_id = all(".state-routing-item")[-1].first("input")["id"].tr('^0-9', '')

      select "Coconut Cooperative", from: "Organization"
      fill_in "hub_state_routing_form[vita_partner_states_attributes][#{unpersisted_field_id}][routing_percentage]", with: 10

      click_on "Save"

      new_vps_id = VitaPartnerState.last.id
      within "#vita_partner_state-#{new_vps_id}" do
        expect(page).to have_text "Coconut Cooperative"
        expect(find_field("hub_state_routing_form[vita_partner_states_attributes][1][routing_percentage]").value).to eq "10"
      end

      expect(find_field("hub_state_routing_form[vita_partner_states_attributes][0][routing_percentage]").value).to eq "90"
      expect(find_field("hub_state_routing_form[vita_partner_states_attributes][1][routing_percentage]").value).to eq "10"
      expect(find_field("hub_state_routing_form[vita_partner_states_attributes][2][routing_percentage]").value).to eq "0"

      within "#vita_partner_state-#{orange_vps.id}" do
        expect(page).to have_css('i.icon-delete_forever')
        page.accept_alert 'Are you sure you want to remove routing for Orange Organization?' do
          find(:css, '.delete-item').click
        end
      end
      expect(page).not_to have_text "Orange Organization"

      click_on "Add routing"
      unpersisted_field_id = all(".state-routing-item")[-1].first("input")["id"].tr('^0-9', '')
      expect(find_field("hub_state_routing_form[vita_partner_states_attributes][#{unpersisted_field_id}][routing_percentage]").value).to eq "0"
      find(:css, '.delete-unpersisted-state-routing-item').click
      expect(find_field("hub_state_routing_form[vita_partner_states_attributes][#{unpersisted_field_id}][routing_percentage]", visible: :hidden, disabled: true)).to be_present
    end
  end
end
