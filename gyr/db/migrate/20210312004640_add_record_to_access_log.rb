class AddRecordToAccessLog < ActiveRecord::Migration[6.0]
  def up
    # add the new columns, we will need to make these "null: false" in a later deploy
    add_reference :access_logs, :record, polymorphic: true
    # set the new columns
    update "UPDATE access_logs SET record_type = 'Client', record_id = client_id"
    # make the old column nullable
    change_column_null :access_logs, :client_id, true
  end

  def down
    # remove the old columns
    remove_reference :access_logs, :record, polymorphic: true
    # we can't reset client_id to null false, it's not safe
  end
end

