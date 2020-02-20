class AddPersonalInformationColumnsToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :was_full_time_student, :integer, default: 0, null: false
    add_column :intakes, :was_on_visa, :integer, default: 0, null: false
    add_column :intakes, :had_disability, :integer, default: 0, null: false
    add_column :intakes, :was_blind, :integer, default: 0, null: false
    add_column :intakes, :issued_identity_pin, :integer, default: 0, null: false

    add_column :intakes, :spouse_was_full_time_student, :integer, default: 0, null: false
    add_column :intakes, :spouse_was_on_visa, :integer, default: 0, null: false
    add_column :intakes, :spouse_had_disability, :integer, default: 0, null: false
    add_column :intakes, :spouse_was_blind, :integer, default: 0, null: false
    add_column :intakes, :spouse_issued_identity_pin, :integer, default: 0, null: false
  end
end
