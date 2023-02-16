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
# Indexes
#
#  index_experiments_on_key  (key) UNIQUE
#
class Experiment < ApplicationRecord
end
