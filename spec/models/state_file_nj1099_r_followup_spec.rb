# == Schema Information
#
# Table name: state_file_nj1099_r_followups
#
#  id            :bigint           not null, primary key
#  income_source :integer          default("unfilled"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFileNj1099RFollowup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
