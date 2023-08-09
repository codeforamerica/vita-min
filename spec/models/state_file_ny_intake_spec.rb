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
require 'rails_helper'

RSpec.describe StateFileNyIntake, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
