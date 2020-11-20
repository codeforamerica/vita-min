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
      user.supported_organizations.map { |so| user.memberships.create(vita_partner_id: so.id, role: "lead")}
    end
  end
end
