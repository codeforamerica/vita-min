class AddParentOrganizationToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_reference :vita_partners, :parent_organization
  end
end
