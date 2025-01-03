class CreateStateFileArchivedIntakes < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_archived_intakes do |t|
      t.integer 'tax_year'
      t.string 'state_code'
      t.string 'hashed_ssn'
      t.string 'email_address'
      t.string 'mailing_street'
      t.string 'mailing_apartment'
      t.string 'mailing_city'
      t.string 'mailing_state'
      t.string 'mailing_zip'
      t.timestamps
    end
  end
end
