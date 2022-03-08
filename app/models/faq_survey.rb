# == Schema Information
#
# Table name: faq_surveys
#
#  id           :bigint           not null, primary key
#  answer       :integer
#  question_key :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  visitor_id   :string
#
# Indexes
#
#  index_faq_surveys_on_visitor_id_and_question_key  (visitor_id,question_key)
#
class FaqSurvey < ApplicationRecord
  enum answer: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :answer
end
