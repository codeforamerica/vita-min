# == Schema Information
#
# Table name: intake_archives
#
#  id                 :bigint           not null, primary key
#  needs_help_2017    :integer
#  spouse_was_on_visa :integer
#  was_on_visa        :integer
#
# Foreign Keys
#
#  fk_rails_...  (id => intakes.id)
#
class IntakeArchive < ApplicationRecord
  belongs_to :intake, foreign_key: :id
  enum needs_help_2017: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2017
end
