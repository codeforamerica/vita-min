class AddProductYearToIntakes < ActiveRecord::Migration[7.0]
  def change
    # Safe enough for migrations since in Dec 2022 there aren't a lot of reads & writes on the web app.
    add_column :intakes, :product_year, :integer, null: false, default: 2022
    change_column_default :intakes, :product_year, nil
  end
end
