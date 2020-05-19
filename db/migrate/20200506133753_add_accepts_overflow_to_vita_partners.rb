class AddAcceptsOverflowToVitaPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :accepts_overflow, :boolean, default: false
  end
end
