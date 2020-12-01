class CreateMemberships < ActiveRecord::Migration[6.0]
  def up
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vita_partner, null: false, foreign_key: true
      t.integer :role, default: 1, null: false

      t.timestamps
    end

    migrate_data
  end

  def down
    drop_table :memberships
  end

  def migrate_data
    User.all.each do |user|
      user.memberships.create(vita_partner_id: user.vita_partner_id)
      # Since supported orgs was trying to create a loose coalition per user and product wants them to be more
      # concrete, copying them over could create more trouble than help, unless this concept is actively being
      # used on demo to support loose coalitions (would also allow us to delete supported organizations and UVP table in this PR).
      # user.supported_organizations.map { |so| user.memberships.create(vita_partner_id: so.id, role: "lead")}
    end
  end
end
