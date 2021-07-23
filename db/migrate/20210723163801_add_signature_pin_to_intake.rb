class AddSignaturePinToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :encrypted_primary_signature_pin, :string
    add_column :intakes, :encrypted_primary_signature_pin_iv, :string

    add_column :intakes, :encrypted_spouse_signature_pin, :string
    add_column :intakes, :encrypted_spouse_signature_pin_iv, :string

    add_column :intakes, :primary_signature_pin_at, :datetime
    add_column :intakes, :spouse_signature_pin_at, :datetime
  end
end
