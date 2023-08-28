# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                 :bigint           not null, primary key
#  current_step       :string
#  mailing_city       :string
#  mailing_street     :string
#  mailing_zip        :string
#  primary_dob        :date
#  primary_first_name :string
#  primary_last_name  :string
#  primary_ssn        :string
#  tax_return_year    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  visitor_id         :string
#
class StateFileAzIntake < ApplicationRecord
  def filing_status
    # TODO
    "single"
  end

  # TODO
  def agi
    1234
  end

  def primary
    Person.new(self, :primary)
  end

  class Person
    attr_reader :first_name
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @birth_date = intake.primary_dob
        @ssn = intake.primary_ssn
      end
    end
  end
end
