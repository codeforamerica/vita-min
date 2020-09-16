# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[6.0]
  # This migration was created automatically by `rails generate devise User` and then edited
  def self.up
    change_table :users do |t|
      ## Database authenticatable - Required for login form - encrypted_password is stored w/ bcrypt, not decryptable
      #t.string :email,              null: false, default: "" # Already exists
      t.string :encrypted_password, null: false, default: "" # should be called "hashed" instead of "encrypted"

      ## Recoverable - Will be used in later commits for password reset
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable - Creates a "[X] Remember me" checkbox not using for now
      #t.datetime :remember_created_at

      ## Trackable - useful for analytics or investigating account takeover
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip

      t.string   :last_sign_in_ip
      ## Confirmable - Not using this yet
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable - Useful for time-based lockouts
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps null: false
    end

    #add_index :users, :email,                unique: true # already exists
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

  def self.down
    # This down method was not created by devise.

    # Remove the created indices
    remove_index :users, :reset_password_token
    # Remove all the added columns
    remove_column :users, :locked_at
    remove_column :users, :failed_attempts
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :encrypted_password
  end
end
