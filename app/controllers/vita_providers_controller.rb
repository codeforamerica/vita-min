class VitaProvidersController < ApplicationController
  helper_method :provider_result_number

  def include_google_analytics?
    true
  end

  def index
    @providers = []
    if provider_search_form_params.present?
      @provider_search_form = ProviderSearchForm.new(provider_search_form_params)
      if @provider_search_form.valid?
        @providers = VitaProvider.sort_by_distance_from_zipcode(@provider_search_form.zip, @provider_search_form.page)
        @zip_name = ZipCodes.details(@provider_search_form.zip)[:name]
      end
    else
      @provider_search_form = ProviderSearchForm.new
    end
  end

  def show
    @provider = VitaProvider.find(params[:id])
    @zip = params[:zip]
    if @zip.present?
      zip_details = ZipCodes.details(@zip)
      @zip_name = zip_details[:name]
      zip_centroid = Geometry.coords_to_point(
        lat: zip_details[:coordinates][0],
        lon: zip_details[:coordinates][1]
      )
      @distance = zip_centroid.distance(@provider.coordinates)
    end
    @page = params[:page]
  end

  private

  def provider_result_number(index)
    page = @provider_search_form.page || 1
    prior_results_count = (page.to_i - 1) * 5
    prior_results_count + (index + 1)
  end

  def provider_search_form_params
    params.permit(:zip, :page)
  end
end