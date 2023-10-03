class Drop1040ColumnsFromStateIntakes < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      columns = [
        :tax_return_year,
        :filing_status,
        :phone_daytime,
        :phone_daytime_area_code,
        :primary_dob,
        :primary_ssn,
        :primary_occupation,
        :spouse_dob,
        :spouse_ssn,
        :spouse_occupation,
        :mailing_city,
        :mailing_street,
        :mailing_apartment,
        :mailing_zip,
        :fed_wages,
        :fed_taxable_income,
        :fed_unemployment,
        :fed_taxable_ssb,
        :total_fed_adjustments_identify,
        :total_fed_adjustments,
        :total_state_tax_withheld,
      ]
      tables = [
        :state_file_az_intakes,
        :state_file_ny_intakes,
      ]
      tables.each do |table|
        columns.each do |column|
          remove_column table, column
        end
      end
    end
  end
end
