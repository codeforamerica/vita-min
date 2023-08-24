class CreateTaxReturnTransitions < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_return_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :tax_return_id, null: false
      t.boolean :most_recent, null: false

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :tax_return_transitions, :tax_returns

    add_index(:tax_return_transitions,
              %i(tax_return_id sort_key),
              unique: true,
              name: "index_tax_return_transitions_parent_sort")
    add_index(:tax_return_transitions,
              %i(tax_return_id most_recent),
              unique: true,
              where: "most_recent",
              name: "index_tax_return_transitions_parent_most_recent")
  end
end
