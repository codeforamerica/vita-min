class AddEmailDomainToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :email_domain, :string
  end
end
