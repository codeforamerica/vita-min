require 'rails_helper'

RSpec.describe EfileErrorPolicy, type: :policy do
  let(:admin_user) { create :admin_user }
  let(:state_file_admin_user) { create :state_file_admin_user }
  let(:nj_staff_user) { create :state_file_nj_staff_user }
  let(:other_user){ create :client_success_user }

  permissions :index?, :show?, :update?, :edit?, :reprocess? do
    let(:policy) { described_class }

    it 'allow access to admin, state file admin, and nj staff user' do
      expect(policy).to permit(admin_user, EfileError)
      expect(policy).to permit(state_file_admin_user, EfileError)
      expect(policy).to permit(nj_staff_user, EfileError)
    end

    it 'denies access to other users' do
      expect(policy).not_to permit(other_user, EfileError)
    end
  end

  permissions ".scope" do
    let!(:nj_efile_error){ create :efile_error, service_type: "state_file_nj" }
    let!(:az_efile_error){ create :efile_error, service_type: "state_file_az" }
    let!(:ctc_efile_error){ create :efile_error, service_type: "ctc" }

    it 'denies access by default' do
      expect(Pundit.policy_scope!(other_user, EfileError)).to be_nil
    end

    it 'access scoped to certain service types' do
      expect(Pundit.policy_scope!(state_file_admin_user, EfileError)).to include(az_efile_error, ctc_efile_error)
      expect(Pundit.policy_scope!(admin_user, EfileError)).to include(ctc_efile_error)
      expect(Pundit.policy_scope!(nj_staff_user, EfileError)).to include(nj_efile_error)
    end
  end
end
