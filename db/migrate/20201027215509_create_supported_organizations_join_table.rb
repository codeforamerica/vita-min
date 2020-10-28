class CreateSupportedOrganizationsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :vita_partners do |t|
      t.index :user_id
      t.index :vita_partner_id
    end
  end
end
