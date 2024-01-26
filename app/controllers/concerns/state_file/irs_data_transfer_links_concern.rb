module StateFile
  module IrsDataTransferLinksConcern
    extend ActiveSupport::Concern

    def data_transfer_link
      link = URI(state_file_fake_direct_file_transfer_page_path)
      link.query = { redirect: return_url }.to_param
      link
    end

    def irs_link
      df_transfer_auth = EnvironmentCredentials.dig('statefile', 'df_transfer_auth')
      if df_transfer_auth
        irs_link = URI(df_transfer_auth)
        irs_link.query = { redirect: return_url }.to_param
      end
      irs_link
    end

    private

    def return_url
      return_url = URI(form_navigation.next.to_path_helper(full_url: true, us_state: params[:us_state]))
      return_url.host = request.host
      return_url
    end
  end
end