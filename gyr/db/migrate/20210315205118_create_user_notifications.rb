class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :read, null: false, default: false
      t.references :notifiable, polymorphic: true
      t.timestamps
    end
  end
end