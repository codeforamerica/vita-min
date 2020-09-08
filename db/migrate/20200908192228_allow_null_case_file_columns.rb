class AllowNullCaseFileColumns < ActiveRecord::Migration[6.0]
  def change
    change_column_null :case_files, :email_address, true
    change_column_null :case_files, :phone_number, true
    change_column_null :case_files, :preferred_name, true
  end
end
