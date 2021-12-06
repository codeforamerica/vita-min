class Archive2021Intakes < ActiveRecord::Migration[6.1]
  def change
    # default index name of `index_archived_intakes_2021_on_[column]` is too long for psql's ridiculous 63 char limit
    columns = %w[
      canonical_email_address
      client_id
      completed_at
      email_address
      email_domain
      needs_to_flush_searchable_data_set_at
      phone_number
      searchable_data
      sms_phone_number
      spouse_email_address
      type
      vita_partner_id
    ]
    columns.each do |column|
      rename_index :intakes, "index_intakes_on_#{column}", "index_arcint_2021_on_#{column}"
    end

    rename_table :intakes, :archived_intakes_2021
  end
end
