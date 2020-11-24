module Hub
  class DropOffClientForm < Form
    include FormAttributes
    set_attributes_for :intake,
      :preferred_name,
      :primary_first_name,
      :primary_last_name,
      :email_address,
      :phone_number,
      :street_address,
      :city,
      :state,
      :zip_code,
      :email_notification_opt_in,
      :needs_help_2019,
      :state_of_residence,
      :additional_info
    set_attributes_for :intake_site_drop_off,
      :signature_method,
      :certification_level,
      :intake_site,
      :organization
    set_attributes_for :document,
      :upload

    def initialize(params = {})
      @intake = Intake.new
      super(params)
    end

    def save
      client = Client.create
      @intake.update(attributes_for(:intake).merge(client: client))
      @intake.filing_years.each do |year|
        TaxReturn.create(client: client, year: year, status: "intake_needs_assignment")
      end
      IntakeSiteDropOff.create!(
        attributes_for(:intake_site_drop_off)
          .merge(
            client: client,
            name: @intake.preferred_name,
            state: @intake.state,
            document_bundle: upload
        )
      )
      Document.create!(
        attributes_for(:document)
          .merge(
            client: client,
            document_type: "Drop-off",
          )
      )
    end
  end
end
