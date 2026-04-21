class CreatePausedEmailDomain < ActiveRecord::Migration[7.1]
  def change
    create_table :paused_email_domains do |t|
      t.citext :domain, null: false
      t.datetime :paused_until
      t.string :reason
      t.timestamps
    end

    add_index :paused_email_domains, :domain, unique: true
    add_index :paused_email_domains, :paused_until
  end
end
