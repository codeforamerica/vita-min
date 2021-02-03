class ChangeIntakeEmailToCaseInsensitiveText < ActiveRecord::Migration[6.0]
  def up
    enable_extension("citext")
    change_column :intakes, :email_address, :citext
    change_column :intakes, :spouse_email_address, :citext
  end

  def down
    change_column :intakes, :email_address, :string
    change_column :intakes, :spouse_email_address, :string
  end
end
