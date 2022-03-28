# == Schema Information
#
# Table name: fraud_indicators
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  description          :text
#  indicator_attributes :string           default([]), is an Array
#  indicator_type       :string
#  list_model_name      :string
#  multiplier           :float
#  name                 :string
#  points               :integer
#  query_model_name     :string
#  reference            :string
#  threshold            :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class FraudIndicator < ApplicationRecord
  TOO_SHORT_MESSAGE = "must have minimum length of %{count}"
  WRONG_LENGTH_MESSAGE = "must have length of %{count}"
  validates :indicator_type, presence: true, inclusion: { in: FraudIndicator.instance_methods - ApplicationRecord.instance_methods }
  validates :points, presence: true
  validates :query_model_name, presence: true
  validates :list_model_name, presence: true, if: -> { indicator_type.in? ["not_in_safelist", "in_denylist"] }
  validates :reference, presence: true, inclusion: { in: ["client", "intake", "efile_submission", "bank_account"] }
  validates :name, presence: true
  validates :query_model_name, :list_model_name, class_name: true
  validates :threshold, numericality: true, if: -> { indicator_type.in? ["average_threshold", "duplicates"] }
  validates :indicator_attributes, length: { is: 1, wrong_length: WRONG_LENGTH_MESSAGE }, if: -> { indicator_type.in? ["average_threshold", "not_in_safelist", "in_denylist", "missing"] }
  validates :indicator_attributes, length: { is: 2, wrong_length: WRONG_LENGTH_MESSAGE }, if: -> { indicator_type.in? ["equals"] }
  validates :indicator_attributes, length: { minimum: 1, too_short: TOO_SHORT_MESSAGE }, if: -> { indicator_type.in? ["duplicates"] }
  validates :multiplier, presence: true, if: -> { indicator_type.in? ["duplicates"] }

  default_scope { where.not(activated_at: nil) }

  def execute(intake: nil, client: nil, efile_submission: nil, bank_account: nil, tax_return: nil)
    references = {
      intake: intake,
      client: client,
      efile_submission: efile_submission,
      tax_return: tax_return,
      bank_account: bank_account
    }.with_indifferent_access
    send(indicator_type, references)
  end

  # Currently only supports checking something as fraudy if average is under a given threshold
  def average_threshold(references)
    attribute = indicator_attributes[0]

    average = scoped_query(references).average(attribute) || 0
    average.blank? || average < threshold
  end

  # returns true (potentially fraudy) when an object exists that is NOT included in the safelist
  def not_in_safelist(references)
    attribute = indicator_attributes[0]
    scoped_query(references).where.not(attribute => comparison_list).exists?
  end

  # returns true (potentially fraudy) when an object exists that is included on the denylist
  def in_denylist(references)
    attribute = indicator_attributes[0]
    scoped_query(references).where(attribute => comparison_list).exists?
  end

  # Returns truthy count when duplicates exist
  # Returns false when no duplicates exist
  def duplicates(references)
    dupes = DeduplificationService.duplicates(references[reference], *indicator_attributes, from_scope: query_model_name.constantize).count
    dupes.positive? ? dupes : false
  end

  # if missing relationship, returns true (fraudy)
  # if relationship exists, returns false
  # do not fail it if there is no present reference object
  def missing(references)
    relationship = indicator_attributes[0]
    # skip this rule if we can't check against the reference object
    return false if references[reference].blank?

    scoped_query(references).where.missing(relationship).exists?
  end

  # returns true if the value is present
  def equals(references)
    attribute = indicator_attributes[0]
    value = indicator_attributes[1]

    scoped_query(references).where(attribute => value).exists?
  end

  private

  def scoped_query(references)
    self_reference = query_model_name.downcase == reference.underscore
    scope = self_reference ? { id: references[reference].id } : { reference => references[reference] }
    query_model_name.constantize.where(scope)
  end

  def comparison_list
    list_model_name.constantize.list
  end
end
