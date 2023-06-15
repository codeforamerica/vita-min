class AddComputedBlurrinessToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :blur_score, :float, default: nil
  end
end
