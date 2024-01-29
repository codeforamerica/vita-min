module StateFile
  module IrsDataTransferLinksConcern
    extend ActiveSupport::Concern

    def fake_data_transfer_link
      return nil if Rails.env.production? || Rails.env.staging?

      fake_df_transfer_page_link = URI(state_file_fake_direct_file_transfer_page_path)
      fake_df_transfer_page_link.query = { redirect: return_url }.to_param
      fake_df_transfer_page_link
    end

    def irs_df_transfer_link
      df_transfer_auth = EnvironmentCredentials.dig('statefile', 'df_transfer_auth')
      return nil unless df_transfer_auth

      if df_transfer_auth
        irs_df_transfer_link = URI(df_transfer_auth)
        irs_df_transfer_link.query = { redirect: return_url }.to_param
      end
      irs_df_transfer_link
    end

    private

    def return_url
      return_url = URI(form_navigation.next.to_path_helper(full_url: true, us_state: params[:us_state]))
      return_url.host = request.host
      return_url
    end
  end
end