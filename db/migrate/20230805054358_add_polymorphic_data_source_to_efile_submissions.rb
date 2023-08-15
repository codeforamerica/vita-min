class AddPolymorphicDataSourceToEfileSubmissions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :efile_submissions, :data_source, polymorphic: true, index: { algorithm: :concurrently }
  end
end
