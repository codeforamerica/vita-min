class AddTaxpayerIdTypesToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :with_social_security_taxpayer_id, :boolean, default: false
    add_column :intakes, :with_itin_taxpayer_id, :boolean, default: false
    add_column :intakes, :with_vita_approved_taxpayer_id, :boolean, default: false
  end
end
