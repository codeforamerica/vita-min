class AddSpouseAuthTokenToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :spouse_auth_token, :string
  end
end
