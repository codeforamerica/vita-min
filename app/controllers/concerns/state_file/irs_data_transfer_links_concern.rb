module StateFile
  module IrsDataTransferLinksConcern
    extend ActiveSupport::Concern

    def data_transfer_link
      link = URI(state_file_fake_direct_file_transfer_page_path)
      link.query = { redirect: return_url }.to_param
      link
    end

    def irs_testing_link
      if ENV["IRS_TRANSFER_AUTH_URL"].present?
        irs_testing_link = URI(ENV["IRS_TRANSFER_AUTH_URL"])
        irs_testing_link.query = { redirect: return_url }.to_param
      end
      irs_testing_link
    end

    private

    def return_url
      return_url = URI(form_navigation.next.to_path_helper(full_url: true, us_state: params[:us_state]))
      return_url.host = request.host
      return_url
    end
  end
end