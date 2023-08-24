class VitaPartnerTypeNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:vita_partners, :type, false)
  end
end
