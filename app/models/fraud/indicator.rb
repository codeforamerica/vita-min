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
module Fraud
  # See Notion for rule descriptions: https://www.notion.so/cfa/Fraud-Rules-2022-b89c29aa9776457aa70f51bc796a58ea
  class Indicator < ApplicationRecord
    self.table_name = "fraud_indicators"

    TOO_SHORT_MESSAGE = "must have minimum length of %{count}"
    WRONG_LENGTH_MESSAGE = "must have length of %{count}"
    validates :indicator_type, presence: true, inclusion: { in: ["missing_relationship", "duplicates", "average_under", "not_in_safelist", "in_riskylist", "execute", "equals"] }
    validates :points, presence: true
    validates :query_model_name, presence: true
    validates :list_model_name, presence: true, if: -> { indicator_type.in? ["not_in_safelist", "in_riskylist"] }
    validates :reference, presence: true, inclusion: { in: ["client", "intake", "efile_submission", "bank_account", "tax_return"] }
    validates :name, presence: true
    validates :query_model_name, :list_model_name, class_name: true
    validates :threshold, numericality: true, if: -> { indicator_type.in? ["average_under", "duplicates"] }
    validates :indicator_attributes, length: { is: 1, wrong_length: WRONG_LENGTH_MESSAGE }, if: -> { indicator_type.in? ["average_under", "not_in_safelist", "in_riskylist", "missing_relationship"] }
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

    def average_under(references)
      attribute = indicator_attributes[0]

      average = scoped_records(references).average(attribute)
      (average.blank? || average < threshold) ? [points, [average]] : [0, [average]]
    end

    def not_in_safelist(references)
      attribute = indicator_attributes[0]
      values = scoped_records(references).where.not(attribute => safelist).pluck(attribute)
      values.present? ? [points, values.uniq] : [0, []]
    end

    def in_riskylist(references)
      attribute = indicator_attributes[0]
      values = scoped_records(references).where(attribute => riskylist).pluck(attribute)
      values.present? ? [points, values.uniq] : [0, []]
    end

    def duplicates(references)
      duplicate_ids = DeduplificationService.duplicates(references[reference], *indicator_attributes, from_scope: query_model_name.constantize).pluck(:id)
      points = calculate_points_from_count(duplicate_ids.count)
      duplicate_ids.present? ? [points, duplicate_ids.uniq] : [0, []]
    end

    def missing_relationship(references)
      # skip this rule if we can't check against the reference object
      return false if references[reference].blank?

      relationship = indicator_attributes[0]

      scoped_records(references).where.missing(relationship).exists? ? [points, []] : [0, []]
    end

    def equals(references)
      attribute = indicator_attributes[0]
      value = indicator_attributes[1]

      scoped_records(references).where(attribute => value).exists? ? [points, []] : [0, []]
    end

    private

    def scoped_records(references)
      self_reference = query_model_name.downcase == reference.underscore
      scope = self_reference ? { id: references[reference].id } : { reference => references[reference] }
      query_model_name.constantize.where(scope)
    end

    def safelist
      list_model_name.constantize.safelist
    end

    def riskylist
      list_model_name.constantize.riskylist
    end

    def calculate_points_from_count(count)
      return points unless multiplier.present?

      applied_count = (count - 1)
      points + (points * (applied_count * applied_count * multiplier)).to_i
    end
  end
end
