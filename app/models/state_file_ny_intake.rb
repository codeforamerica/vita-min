# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                 :bigint           not null, primary key
#  primary_first_name :string
#  primary_last_name  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class StateFileNyIntake < ApplicationRecord
  def primary
    Person.new(self, :primary)
  end

  # TODO
  def tp_id
    "123456789"
  end

  # TODO
  def tax_return_year
    2022
  end

  # TODO
  def street_address
    "1 French Fry Way"
  end

  # TODO
  def city
    "Albany"
  end

  # TODO
  def zip_code
    "12084"
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
        # TODO
        @birth_date = 38.years.ago
        @ssn = '123221234'
      end
    end
  end
end