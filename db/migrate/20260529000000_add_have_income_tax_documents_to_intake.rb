class AddHaveIncomeTaxDocumentsToIntake < ActiveRecord::Migration[7.2]
  def change
    add_column :intakes, :have_income_tax_documents, :integer, default: 0
  end
end
