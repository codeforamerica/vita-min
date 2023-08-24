class ActiveStorage::Representations::RedirectController < ActiveStorage::Representations::BaseController
  def show
    Timeout.timeout(5) do
      @representation = @blob.representation(params[:variation_key]).processed
      expires_in ActiveStorage.service_urls_expire_in
      redirect_to @representation.url(disposition: params[:disposition])
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    head :not_found
  rescue
    redirect_to ActionController::Base.helpers.asset_path('document.svg')
  end

  private

  def set_representation
    # the assignment of `@representation =` from BaseController is inlined into `show`
    # so we can wrap the whole thing in the same timeout/rescue logic
  end
end
