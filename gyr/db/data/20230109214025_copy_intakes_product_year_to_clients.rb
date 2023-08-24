# frozen_string_literal: true

class CopyIntakesProductYearToClients < ActiveRecord::Migration[7.0]
  class Intake < ApplicationRecord
    self.inheritance_column = 'not_a_real_column'

    belongs_to :client, inverse_of: :intake, optional: true
  end

  class Client < ApplicationRecord
    has_one :intake, inverse_of: :client, dependent: :destroy
  end

  def up
    intake_product_years = Intake.group(:product_year).count.keys
    if intake_product_years == [2022]
      Client.joins(:intake).in_batches(of: 10_000) do |client_batch|
        client_batch.update_all('filterable_product_year = 2022')
      end
    end
  end

  def down
  end
end
