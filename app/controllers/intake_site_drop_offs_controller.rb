class IntakeSiteDropOffsController < ApplicationController
  def new
    @drop_off = IntakeSiteDropOff.new(intake_site: session[:intake_site])
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
      session[:intake_site] = @drop_off.intake_site
      if @drop_off.prior_drop_off.present?
        ZendeskDropOffService.new(@drop_off).append_to_existing_ticket
        track_append_to_drop_off
      else
        zendesk_ticket_id = ZendeskDropOffService.new(@drop_off).create_ticket
        @drop_off.update(zendesk_ticket_id: zendesk_ticket_id)
        track_create_drop_off
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

  def track_append_to_drop_off
    event_data = mixpanel_data
    send_mixpanel_event(event_name: "append_to_drop_off", data: event_data)
  end

  def track_create_drop_off
    event_data = mixpanel_data
    send_mixpanel_event(event_name: "create_drop_off", data: event_data)
  end

  def mixpanel_data
    {
      organization: @organization,
      intake_site: @drop_off.intake_site,
      state: @drop_off.state,
      signature_method: @drop_off.signature_method,
      certification_level: @drop_off.certification_level,
      hsa: @drop_off.hsa,
    }
  end

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