class ExposeErrorDefaultFalseEfileError < ActiveRecord::Migration[7.1]
  def change
    change_column_default :efile_errors, :expose, from: true, to: false
  end
end
