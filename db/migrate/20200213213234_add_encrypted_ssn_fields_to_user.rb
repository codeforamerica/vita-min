class AddEncryptedSsnFieldsToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :encrypted_ssn, :string
    add_column :users, :encrypted_ssn_iv, :string

    # Copy all un-encrypted SSNs to the `encrypted_ssn` column.
    User.find_each do |u|
      previous_ssn = u[:ssn]
      u.update_attribute(:ssn, previous_ssn)
    end

    remove_column :users, :ssn
  end

  def down
    add_column :users, :ssn, :string

    # Copy all encrypted SSNs to the unencrypted `ssn` column.
    User.find_each do |u|
      previous_ssn = u.ssn
      u.update_column(:ssn, previous_ssn)
    end

    remove_column :users, :encrypted_ssn
    remove_column :users, :encrypted_ssn_iv
  end
end
