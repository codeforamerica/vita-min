require 'rails_helper'

describe "cleanup_orphaned_users:find_orphaned_users" do
  include_context "rake"

  around { |example| capture_output { example.run } }

  before(:all) do
    Rails.application.load_tasks
  end

  let!(:team_member_user) { create :team_member_user }
  let!(:admin_user) { create :admin_user }

  context "when there are users without roles" do

    before do
      team_member_user.role.destroy
      admin_user.role.destroy
    end

    it "it finds users without roles" do
      expect {
        task.invoke
      }.to output(/These users have no roles: \[#{admin_user.id}, #{team_member_user.id}]/).to_stdout
    end
  end
end

describe "cleanup_orphaned_users:replace_user_associations_and_delete_old_user" do
  include_context "rake"

  around { |example| capture_output { example.run } }

  before(:all) do
    Rails.application.load_tasks
  end

  let!(:team_member_user) { create :team_member_user }
  let!(:admin_user) { create :admin_user }

  context "when old and new user exists" do
    let!(:new_user){ create :team_member_user}
    let!(:old_user){ create :team_member_user}
    let!(:access_log) { create :access_log, user: old_user }
    let!(:note) { create :note, user: old_user }

    before do
      old_user.role.destroy
    end

    it "it finds users without roles" do
      task.invoke(old_user.id, new_user.id)
      expect(access_log.reload.user).to eq new_user
      expect(note.reload.user).to eq new_user
    end
  end
end
