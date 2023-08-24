class AddProcessesCtcToVitaPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :processes_ctc, :boolean, default: false
  end
end
