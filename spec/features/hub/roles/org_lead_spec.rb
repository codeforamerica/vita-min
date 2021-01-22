require "rails_helper"

describe "Org Lead" do
  let(:org) { create :organization }
  let!(:site) { create :site, parent_organization: org }
  let(:user) { create :organization_lead_user, organization: org }
  let(:client) { create :client, vita_partner: org }
  let!(:intake) { create :intake, client: client }

  before { login_as user }

  it "allows me to assign a client to a site within my organization" do
    visit hub_client_path(id: client.id)

    within(".client-header__organization") do
      click_on "Edit"
    end

    select site.name, from: "Organization"

    click_on "Save"

    within(".client-header__organization") do
      expect(page).to have_content(site.name)
    end
  end
end