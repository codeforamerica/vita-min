class BackfillRawDfTaxReturnDataWithRawDfData < ActiveRecord::Migration[7.1]
  def change
    StateFileAzIntake.find_each do |intake|
      intake.update(raw_direct_file_tax_return_data: intake.raw_direct_file_data)
    end
    StateFileNcIntake.find_each do |intake|
      intake.update(raw_direct_file_tax_return_data: intake.raw_direct_file_data)
    end
    StateFileNjIntake.find_each do |intake|
      intake.update(raw_direct_file_tax_return_data: intake.raw_direct_file_data)
    end
    StateFileNyIntake.find_each do |intake|
      intake.update(raw_direct_file_tax_return_data: intake.raw_direct_file_data)
    end
  end
end
