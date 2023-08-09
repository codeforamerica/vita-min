# == Schema Information
#
# Table name: state_file_ny_intakes
#
#  id                 :bigint           not null, primary key
#  birth_date         :date
#  city               :string
#  current_step       :string
#  primary_first_name :string
#  primary_last_name  :string
#  ssn                :string
#  street_address     :string
#  tax_return_year    :integer
#  zip_code           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tp_id              :string
#  visitor_id         :string
#
class StateFileNyIntake < ApplicationRecord
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
        @birth_date = intake.birth_date
        @ssn = intake.ssn
      end
    end
  end
end
