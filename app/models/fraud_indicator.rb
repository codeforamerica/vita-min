# == Schema Information
#
# Table name: fraud_indicators
#
#  id                   :bigint           not null, primary key
#  active_at            :datetime
#  indicator_attributes :string           default([]), is an Array
#  indicator_type       :string
#  list_table_name      :string
#  multiplier           :decimal(, )
#  name                 :string
#  points               :integer
#  reference            :string
#  source_table_name    :string
#  threshold            :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class FraudIndicator < ApplicationRecord
  validates :indicator_type, presence: true, inclusion: { in: FraudIndicator.instance_methods - ApplicationRecord.instance_methods }
  validates :points, presence: true
  validates :list_table_name, presence: true, if: -> { indicator_type.in? ["safelist", "denylist"] }
  validates :reference, presence: true, inclusion: { in: ["client", "intake", "efile_submission", "bank_account"] }
  validates :name, presence: true
  validates :source_table_name, :list_table_name, class_name: true
  validates :threshold, numericality: true, if: -> { indicator_type.in? ["average_threshold", "duplicates"] }
  validates :indicator_attributes, length: { is: 1 }, if: -> { indicator_type.in? ["average_threshold", "safelist", "denylist", "missing"] }
  validates :indicator_attributes, length: { is: 2 }, if: -> { indicator_type.in? ["particular_value"] }
  validates :indicator_attributes, length: { minimum: 1 }, if: -> { indicator_type.in? ["duplicates"] }
  validates :multiplier, presence: true, if: -> { indicator_type.in? ["duplicates"] }

  default_scope { where.not(active_at: nil) }

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
  def safelist(references)
    attribute = indicator_attributes[0]
    scoped_query(references).where.not(attribute => comparison_list).exists?
  end

  # returns true (potentially fraudy) when an object exists that is included on the denylist
  def denylist(references)
    attribute = indicator_attributes[0]
    scoped_query(references).where(attribute => comparison_list).exists?
  end

  # Returns truthy count when duplicates exist
  # Returns false when no duplicates exist
  def duplicates(references)
    dupes = DeduplificationService.duplicates(references[reference], *indicator_attributes, from_scope: source_table_name.constantize).count
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
  def particular_value(references)
    attribute = indicator_attributes[0]
    value = indicator_attributes[2]

    scoped_query(references).where(attribute => value).exists?
  end

  private

  def scoped_query(references)
    self_reference = source_table_name.downcase == reference.underscore
    scope = self_reference ? { id: references[reference].id } : { reference => references[reference] }
    source_table_name.constantize.where(scope)
  end

  def comparison_list
    list_table_name.constantize.list
  end
end
