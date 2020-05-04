class RenameVitaPartnerColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :vita_partners, :referral_code, :source_parameter
    rename_column :vita_partners, :logo_url, :logo_path
    remove_column :vita_partners, :drop_off_code, :string
  end
end
