require 'rails_helper'

RSpec.describe Hub::AdminToolsController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index
  end
end
