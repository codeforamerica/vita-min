class AddAssistsItinApplicantsToVitaPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :vita_partners, :accepts_itin_applicants, :boolean, default: false
  end
end
