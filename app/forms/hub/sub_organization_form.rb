module Hub
  class SubOrganizationForm < Form
    include FormAttributes
    set_attributes_for :vita_partner, :display_name, :parent_organization_id, :name
    validates :name, presence: true, allow_blank: false

    def initialize(vita_partner, params = {})
      @vita_partner = vita_partner
      super(params)
    end

    def save
      VitaPartner.create!(name: name,
                          display_name: display_name.presence || name,
                          parent_organization_id: parent_organization_id,
                          zendesk_instance_domain: "required-field-but-value-unused",
                          zendesk_group_id: "required-field-but-value-unused")
    end
  end
end
