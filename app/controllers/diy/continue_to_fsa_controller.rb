module Diy
  class ContinueToFsaController < BaseController
    before_action :require_diy_intake

    def edit
      @taxslayer_link = taxslayer_link
    end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end

    def taxslayer_link
      gyr_sources = %w[2022-taxes 2022_taxes 22-claim]
      if gyr_sources.include?(source)
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934"
      else
        EnvironmentCredentials.dig(:tax_slayer_link)
      end
    end
  end
end
