require "rails_helper"

describe "Site Coordinator" do
  let(:site) { create :site }
  let(:user) { create :site_coordinator_user, site: site }
  let(:client) { create :client, vita_partner: site}
  let!(:intake) { create :intake, client: client }
  let!(:tax_return) { create :tax_return, client: client, assigned_user: nil }
  let!(:team_member) { create :team_member_user, site: site }

  before { login_as user }

  it "allows me to assign tax returns to users within my site", js: true do
    visit hub_client_path(id: client.id)

    click_on "Assign"

    select team_member.name, from: "Assign to"

    click_on "Save"

    within(".tax-return-list__assignee") do
      expect(page).to have_content team_member.name
    end
  end
end