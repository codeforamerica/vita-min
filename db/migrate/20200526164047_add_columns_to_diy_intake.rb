class AddColumnsToDiyIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :diy_intakes, :visitor_id, :string
    add_column :diy_intakes, :source, :string
    add_column :diy_intakes, :referrer, :string
  end
end
