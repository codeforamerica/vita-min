class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Add a fake ignored column to cause Rails to not do "SELECT *";
  # this avoids PreparedStatementCacheExpired exceptions.
  # Based on https://flexport.engineering/avoiding-activerecord-preparedstatementcacheexpired-errors-4499a4f961cf
  #
  # Migrate to enumerate_columns_in_select_statements when we switch to Rails 7
  # https://www.bigbinary.com/blog/rails-7-adds-setting-for-enumerating-columns-in-select-statements
  class_attribute :ignored_columns, default: [:__fake_column__]

  # Allow counting up to a max number; see https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/#how-far-do-you-plan-to-count
  scope :more_than, ->(n) { limit(n + 1).count > n }
end
