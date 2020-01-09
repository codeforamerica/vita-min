class IntakeSiteDropOffsController < ApplicationController
  def new
    @drop_off = IntakeSiteDropOff.new
    @organization = params[:organization]
    @drop_off.state = default_state_for_org(@organization)
  end

  def create
    @drop_off = IntakeSiteDropOff.new(intake_site_drop_off_params)
    @organization = params[:organization]
    @drop_off.organization = @organization
    # check for matching drop offs
    @drop_off.add_prior_drop_off_if_present!
    if @drop_off.save
      if @drop_off.prior_drop_off.present?
        ZendeskDropOffService.new(@drop_off).append_to_existing_ticket
      else
        zendesk_ticket_id = ZendeskDropOffService.new(@drop_off).create_ticket
        @drop_off.update(zendesk_ticket_id: zendesk_ticket_id)
      end
      redirect_to show_drop_off_path(id: @drop_off, organization: @organization)
    else
      render :new
    end
  end

  def show
    @drop_off = IntakeSiteDropOff.find(params[:id])
    @organization = params[:organization]
  end

  private

  def default_state_for_org(organization)
    organization == "thc" ? "co" : "ga"
  end

  def intake_site_drop_off_params
    params.require(:intake_site_drop_off).permit(
      :name,
      :email,
      :phone_number,
      :intake_site,
      :state,
      :signature_method,
      :pickup_date_string,
      :document_bundle,
      :certification_level,
      :hsa,
      :additional_info,
      :timezone,
    )
  end
end