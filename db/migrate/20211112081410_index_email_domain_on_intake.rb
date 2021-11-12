class IndexEmailDomainOnIntake < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :intakes, :email_domain, algorithm: :concurrently
  end
end
