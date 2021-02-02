class ChangeIntakeEmailToCaseInsensitiveText < ActiveRecord::Migration[6.0]
  def up
    enable_extension("citext")
    change_column :intakes, :email_address, :citext
    change_column :intakes, :spouse_email_address, :citext
  end

  def down
    enable_extension("citext")
    change_column :intakes, :email_address, :text
    change_column :intakes, :spouse_email_address, :text
  end
end
