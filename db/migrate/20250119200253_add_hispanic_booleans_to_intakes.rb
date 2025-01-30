class AddHispanicBooleansToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :demographic_primary_hispanic_latino, :boolean
    add_column :intakes, :demographic_spouse_hispanic_latino, :boolean
  end
end
