class RemoveNonNullConstraintFromIncomingEmailBodyPlain < ActiveRecord::Migration[6.1]
  def change
    change_column_null :incoming_emails, :body_plain, true
  end
end
