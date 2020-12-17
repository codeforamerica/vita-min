require "rails_helper"

describe RoleHelper do
  describe '#user_roles' do
    context "an admin" do
      let(:user) { create :admin_user }
      it 'returns the user roles' do
        expect(helper.user_roles(user)).to eq "Admin"
      end
    end

    context "as an org lead" do
      let(:user) { create :user }
      before do
        create :organization_lead_role, user: user
      end

      it 'shows they are an org lead' do
        expect(helper.user_roles(user)).to eq "Organization lead"
      end
    end
  end
end
