module Hub
  class SubOrganizationForm < Form
    include FormAttributes
    set_attributes_for :vita_partner, :parent_organization_id, :name
    validates :name, presence: true, allow_blank: false

    def initialize(vita_partner, params = {})
      @vita_partner = vita_partner
      super(params)
    end

    def save
      VitaPartner.create!(name: name,
                          parent_organization_id: parent_organization_id)
    end
  end
end
