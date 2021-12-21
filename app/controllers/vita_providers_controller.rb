class VitaProvidersController < ApplicationController
  METERS_IN_MILE = 1609.34
  helper_method :provider_result_number

  def include_analytics?
    true
  end

  def index
    @providers = []
    if provider_search_form_params.present?
      @provider_search_form = ProviderSearchForm.new(provider_search_form_params)
      @zip = @provider_search_form.zip
      @page = (@provider_search_form.page || "1")
      if @provider_search_form.valid?
        @providers = VitaProvider.sort_by_distance_from_zipcode(@zip, @page)
        @zip_name = ZipCodes.details(@zip)[:name]

        if @providers.count > 0
          track_provider_search
        else
          track_provider_search_no_results
        end
      else
        track_provider_search_bad_zip
      end
    else
      @provider_search_form = ProviderSearchForm.new
    end
  end

  def show
    @provider = VitaProvider.find(params[:id])
    @zip = params[:zip]
    @page = params[:page]
    if @zip.present? && ZipCodes.details(@zip)
      zip_details = ZipCodes.details(@zip)
      @zip_name = zip_details[:name]
      zip_centroid = Geometry.coords_to_point(
        lat: zip_details[:coordinates][0],
        lon: zip_details[:coordinates][1]
      )
      @distance = zip_centroid.distance(@provider.coordinates)
    end

    track_provider_page_view
  end

  def map
    @provider = VitaProvider.find(params[:id])
    track_provider_page_map_click

    redirect_to @provider.google_maps_url
  end

  private

  def track_provider_search
    event_data = {
      zip: @zip,
      zip_name: @zip_name,
      result_count: @providers.total_entries.to_s,
      distance_to_closest_result: (@providers.first&.cached_query_distance / METERS_IN_MILE).round,
      page: @page,
    }
    send_mixpanel_event(event_name: "provider_search", data: event_data)
  end

  def track_provider_search_no_results
    event_data = {
      zip: @zip,
      zip_name: @zip_name,
    }
    send_mixpanel_event(event_name: "provider_search_no_results", data: event_data)
  end

  def track_provider_search_bad_zip
    send_mixpanel_event(event_name: "provider_search_bad_zip", data: { zip: @zip })
  end

  def track_provider_page_view
    event_data = {
      provider_id: @provider.id.to_s,
      provider_name: @provider.name,
    }
    if @zip.present? && @distance.present?
      event_data = event_data.merge({
        provider_searched_zip: @zip,
        provider_searched_zip_name: @zip_name,
        provider_distance_to_searched_zip: (@distance / METERS_IN_MILE).round,
      })
    end
    if params[:page].present?
      event_data[:provider_search_result_page] = params[:page]
    end
    send_mixpanel_event(event_name: "provider_page_view", data: event_data)
  end

  def track_provider_page_map_click
    event_data = {
      provider_name: @provider.name,
      provider_id: @provider.id.to_s,
    }
    send_mixpanel_event(event_name: "provider_page_map_click", data: event_data)
  end

  def provider_result_number(index)
    page = @provider_search_form.page || 1
    prior_results_count = (page.to_i - 1) * 5
    prior_results_count + (index + 1)
  end

  def provider_search_form_params
    params.permit(:zip, :page)
  end
end
