require 'digest'

class UpgradeUsersDeviseInvitations < ActiveRecord::Migration[8.1]
  def up
    create_table :devise_invitations do |t|
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.datetime :superseded_at
      t.string :superseded_reason
      t.datetime :revoked_at
      t.datetime :resource_created_at
      t.json :invite_key, null: false, default: {}
      t.string :invite_key_digest, null: false
      t.references :invitable, polymorphic: true
      t.references :invited_by, polymorphic: true
      t.timestamps
    end
    add_index :devise_invitations, :invitation_token, unique: true
    add_index :devise_invitations, [:invitable_type, :invite_key_digest],
              name: 'index_devise_invitations_on_type_and_invite_key'

    resource_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      self.inheritance_column = :_type_disabled
    end
    invitation_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'devise_invitations'
    end

    resource_class.where.not(invitation_created_at: nil).find_each do |resource|
      invite_key = { "email" => resource.email }
      invitation_class.create!(
        invitation_token: resource.invitation_token,
        invitation_created_at: resource.invitation_created_at,
        invitation_sent_at: resource.invitation_sent_at,
        invitation_accepted_at: resource.invitation_accepted_at,
        resource_created_at: resource.invitation_created_at,
        invite_key: invite_key,
        invite_key_digest: Digest::SHA256.hexdigest(['User', 'email', resource.email.to_s].join("\0")),
        invitable_type: 'User',
        invitable_id: resource.id,
        invited_by_type: resource.invited_by_id.present? ? 'User' : nil,
        invited_by_id: resource.invited_by_id,
        created_at: resource.invitation_created_at,
        updated_at: resource.invitation_accepted_at || resource.invitation_sent_at || resource.invitation_created_at
      )
    end
  end

  def down
    drop_table :devise_invitations
  end
end
