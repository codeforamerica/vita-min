class CreateInternalEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :internal_emails do |t|
      t.string :mail_class
      t.string :mail_method
      t.jsonb :mail_args, default: {}

      t.timestamps
    end
  end
end
