require "rails_helper"

describe Hub::AdminTogglesController, type: :controller do
  describe '#index' do
    it_behaves_like :a_get_action_for_admins_only, action: :index
  end

  describe '#create' do
    let(:params) do
      {
        admin_toggle: {
          name: 'cool_feature'
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :create
  end
end
