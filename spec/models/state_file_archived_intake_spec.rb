# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                    :bigint           not null, primary key
#  email_address         :string
#  failed_attempts       :integer          default(0), not null
#  fake_address_1        :string
#  fake_address_2        :string
#  hashed_ssn            :string
#  locked_at             :datetime
#  mailing_apartment     :string
#  mailing_city          :string
#  mailing_state         :string
#  mailing_street        :string
#  mailing_zip           :string
#  permanently_locked_at :datetime
#  state_code            :string
#  tax_year              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFileArchivedIntake, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
