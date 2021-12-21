class BackfillTypeOnVitaPartner < ActiveRecord::Migration[6.0]

  def up
    ActiveRecord::Base.connection.execute(
      "UPDATE vita_partners SET type='Organization' WHERE parent_organization_id IS NULL"
    )

    ActiveRecord::Base.connection.execute(
      "UPDATE vita_partners SET type='Site' WHERE parent_organization_id IS NOT NULL"
    )
  end

  def down
    VitaPartner.all.update_all(type: nil)
  end
end
