require "rails_helper"

describe RoleHelper do
  describe '#user_roles' do
    context "an admin beta tester" do
      let(:user) { create :admin_user }
      it 'returns the user roles' do
        expect(helper.user_roles(user)).to eq "Admin, Beta tester"
      end
    end

    context "a beta tester only" do
      let(:user) { create :beta_tester }
      it 'returns the user roles' do
        expect(helper.user_roles(user)).to eq "Beta tester"
      end
    end
  end
end