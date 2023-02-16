# == Schema Information
#
# Table name: experiments
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(FALSE)
#  key        :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Experiment < ApplicationRecord
end
