require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeOrganizationController do
  describe "#edit" do
    let(:client_selection) { create :client_selection }
    let(:params) { { client_selection_id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    # are we creating a new record?
    # do we need it? What's the output?
    # for message send, it def needs a record, but for others though?
    # how is client_selection being passed into this controller?
  end
end
