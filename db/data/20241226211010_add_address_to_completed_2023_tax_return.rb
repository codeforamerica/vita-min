# frozen_string_literal: true

class AddAddressToCompleted2023TaxReturn < ActiveRecord::Migration[7.1]
  def up
    puts "Migrating Arizona details"
    StateFileAzIntake.all.each do |intake|
      completed_return = Completed2023TaxReturn.new
      completed_return.mailing_street = intake.direct_file_data.mailing_street
      completed_return.mailing_apartment = intake.direct_file_data.mailing_apartment
      completed_return.mailing_city = intake.direct_file_data.mailing_city
      completed_return.mailing_state = intake.direct_file_data.mailing_state
      completed_return.mailing_zip = intake.direct_file_data.mailing_zip
      completed_return.email_address = intake.email_address
      completed_return.state_code = 'az'
      completed_return.hashed_ssn = intake.hashed_ssn
      completed_return_pdf = Completed2023TaxReturnPdf.new

    end

    puts "Migrating New York details"
    StateFileNyIntake.all.each do |intake|
      completed_return = Completed2023TaxReturn.new
      completed_return.mailing_street = intake.direct_file_data.mailing_street
      completed_return.mailing_apartment = intake.direct_file_data.mailing_apartment
      completed_return.mailing_city = intake.direct_file_data.mailing_city
      completed_return.mailing_state = intake.direct_file_data.mailing_state
      completed_return.mailing_zip = intake.direct_file_data.mailing_zip
      completed_return.email_address = intake.email_address
      completed_return.state_code = 'ny'
      completed_return.hashed_ssn = intake.hashed_ssn
      completed_return_pdf = Completed2023TaxReturnPdf.new

    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
