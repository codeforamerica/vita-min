class ArchiveVisaColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :intake_archives, :was_on_visa, :integer
    add_column :intake_archives, :spouse_was_on_visa, :integer
  end
end
