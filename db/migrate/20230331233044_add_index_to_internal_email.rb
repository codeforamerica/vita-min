class AddIndexToInternalEmail < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index(:internal_emails, [:mail_class, :mail_method, :mail_args], algorithm: :concurrently, name: :idx_internal_emails_mail_info)
  end
end
