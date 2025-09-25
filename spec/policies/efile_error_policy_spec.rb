require 'rails_helper'

RSpec.describe EfileErrorPolicy, type: :policy do
  let(:admin_user) { create :admin_user }
  let(:state_file_admin_user) { create :state_file_admin_user }
  let(:nj_staff_user) { create :state_file_nj_staff_user }
  let(:other_user){ create :client_success_user }
  let(:policy) { described_class }

  permissions :index? do
    it 'allow access to admin, state file admin, and nj staff user' do
      expect(policy).to permit(admin_user, EfileError)
      expect(policy).to permit(state_file_admin_user, EfileError)
      expect(policy).to permit(nj_staff_user, EfileError)
    end

    it 'denies access to other users' do
      expect(policy).not_to permit(other_user, EfileError)
    end
  end

  permissions :show?, :update?, :edit?, :reprocess? do
    let(:efile_error){ create :efile_error, service_type: service_type }
    let(:service_type) { "state_file_nj" }

    context "when record has a service type of state_file_nj" do
      it "only permits state_file_nj_staff access the efile error" do
        expect(policy).to permit(nj_staff_user, efile_error)
        expect(policy).not_to permit(admin_user, efile_error)
        expect(policy).not_to permit(state_file_admin_user, efile_error)
      end
    end

    context "when record has a service type of state_file_az" do
      let(:service_type) { "state_file_az" }
      it "only permits state file admins to access the efile error" do
        expect(policy).not_to permit(nj_staff_user, efile_error)
        expect(policy).not_to permit(admin_user, efile_error)
        expect(policy).to permit(state_file_admin_user, efile_error)
      end
    end

    context "when record has a service type of ctc" do
      let(:service_type) { "ctc" }
      it "only permits state file admins and admins to access the efile error" do
        expect(policy).not_to permit(nj_staff_user, efile_error)
        expect(policy).to permit(admin_user, efile_error)
        expect(policy).to permit(state_file_admin_user, efile_error)
      end
    end

    it 'denies access to other users' do
      expect(policy).not_to permit(other_user, efile_error)
    end
  end

  permissions ".scope" do
    let!(:nj_efile_error) { create :efile_error, service_type: "state_file_nj" }
    let!(:az_efile_error) { create :efile_error, service_type: "state_file_az" }
    let!(:ctc_efile_error) { create :efile_error, service_type: "ctc" }

    context "when the user is not an admin" do
      it 'denies access' do
        expect(Pundit.policy_scope!(other_user, EfileError)).to be_empty
      end
    end

    context "when the user is an admin" do
      it 'access scoped to certain service types' do
        expect(Pundit.policy_scope!(state_file_admin_user, EfileError)).to include(az_efile_error, ctc_efile_error)
        expect(Pundit.policy_scope!(admin_user, EfileError)).to include(ctc_efile_error)
        expect(Pundit.policy_scope!(nj_staff_user, EfileError)).to include(nj_efile_error)
      end
    end
  end
end
