class RenameClientEfileSecurityInformationToRemoveNamespace < ActiveRecord::Migration[6.0]
  def change
    rename_table :client_efile_security_informations, :efile_security_informations
  end
end
