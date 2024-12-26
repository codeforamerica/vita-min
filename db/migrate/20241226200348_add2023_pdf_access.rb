class Add2023PdfAccess < ActiveRecord::Migration[7.1]
  def change
    create_table :completed_2023_tax_returns do |t|
      t.string "state_code"
      t.citext "email_address"
      t.string "hashed_ssn"
      t.string "mailing_street"
      t.string "mailing_apartment"
      t.string "mailing_city"
      t.string "mailing_state"
      t.string "mailing_zip"
      t.timestamps
    end
  end
end
