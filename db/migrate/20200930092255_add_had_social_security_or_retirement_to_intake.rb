class AddHadSocialSecurityOrRetirementToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :had_social_security_or_retirement, :integer, default: 0, null: false
  end
end
