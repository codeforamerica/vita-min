class ChangeFiled2019ToFiledPreviousYear < ActiveRecord::Migration[6.1]
  def change
    rename_column :intakes, :filed_2019, :filed_prior_tax_year
    rename_column :intakes, :spouse_filed_2019, :spouse_filed_prior_tax_year
  end
end
