class AddExtraFieldsToDelayedJob < ActiveRecord::Migration[6.0]
  def change
    add_column :delayed_jobs, :job_class, :string
    add_column :delayed_jobs, :job_object_id, :bigint
    add_column :delayed_jobs, :active_job_id, :string
  end
end
