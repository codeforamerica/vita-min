class ChangeDefaultValueforAllowsGreeters < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:vita_partners, :allows_greeters, from: nil, to: true)
  end
end
