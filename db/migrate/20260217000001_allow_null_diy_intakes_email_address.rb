class AllowNullDiyIntakesEmailAddress < ActiveRecord::Migration[7.1]
  def change
    change_column_null :diy_intakes, :email_address, true
    change_column_null :diy_intakes, :filing_frequency, true
  end
end
