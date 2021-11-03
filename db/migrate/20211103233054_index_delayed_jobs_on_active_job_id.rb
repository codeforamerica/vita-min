class IndexDelayedJobsOnActiveJobId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :delayed_jobs, :active_job_id, algorithm: :concurrently
  end
end
