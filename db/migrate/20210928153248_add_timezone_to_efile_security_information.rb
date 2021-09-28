class AddTimezoneToEfileSecurityInformation < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_security_informations, :timezone, :string
  end
end
