require "rails_helper"

RSpec.describe "Creating and reviewing bulk edits" do
  let(:user) { create :organization_lead_user }
  before do
    login_as user
  end

  scenario "creating and reviewing a bulk edit" do
    # creation process should be added, but until then, we'll create one for the tail end of the feature spec
    clients = create_list :client_with_intake_and_return, 3, status: "prep_info_requested", vita_partner: user.role.organization
    client_selection = create :client_selection, clients: clients

    # only have a view of the client selection so far
    visit hub_client_selection_path(id: client_selection.id)
  end
end