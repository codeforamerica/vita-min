# == Schema Information
#
# Table name: intake_archives
#
#  id                    :bigint           not null, primary key
#  had_student_in_family :integer
#  needs_help_2017       :integer
#  spouse_was_on_visa    :integer
#  was_on_visa           :integer
#
# Foreign Keys
#
#  fk_rails_...  (id => intakes.id)
#
class IntakeArchive < ApplicationRecord
  belongs_to :intake, foreign_key: :id
  # enum needs_help_2016: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2016 # or is this only on the other archived intakes
  enum needs_help_2017: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2017
  # enum needs_help_2018: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2018
  # enum needs_help_2019: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2019
  # enum needs_help_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needs_help_2020
  enum spouse_was_on_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_was_on_visa
  enum was_on_visa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_on_visa
  enum had_student_in_family: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :had_student_in_family
end
