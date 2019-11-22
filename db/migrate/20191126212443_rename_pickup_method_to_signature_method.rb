class RenamePickupMethodToSignatureMethod < ActiveRecord::Migration[5.2]
  def change
    rename_column :intake_site_drop_offs, :pickup_method, :signature_method
  end
end
