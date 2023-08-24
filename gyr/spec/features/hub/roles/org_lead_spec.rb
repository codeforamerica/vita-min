require "rails_helper"

describe "Org Lead" do
  let(:org) { create :organization }
  let!(:site) { create :site, parent_organization: org }
  let(:user) { create :organization_lead_user, organization: org }
  let(:client) { create :client, vita_partner: org }
  let!(:intake) { create :intake, client: client }

  before { login_as user }

  it "allows me to assign a client to a site within my organization", js: true do
    visit hub_client_path(id: client.id)

    within(".client-header__organization") do
      click_on "Edit"
    end

    expect(page).to have_text "Organization"
    fill_in_tagify '.select-vita-partner', site.name

    click_on "Save"

    within(".client-header__organization") do
      expect(page).to have_content(site.name)
    end
  end
end