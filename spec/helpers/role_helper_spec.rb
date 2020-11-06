require "rails_helper"

describe RoleHelper do
  describe '#user_roles' do
    context "an admin" do
      let(:user) { create :admin_user }
      it 'returns the user roles' do
        expect(helper.user_roles(user)).to eq "Admin"
      end
    end
  end
end