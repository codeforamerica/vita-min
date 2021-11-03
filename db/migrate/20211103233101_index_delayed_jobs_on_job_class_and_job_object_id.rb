class IndexDelayedJobsOnJobClassAndJobObjectId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :delayed_jobs, [:job_class, :job_object_id], algorithm: :concurrently
  end
end
