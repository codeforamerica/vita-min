module ClientSortable
  extend ActiveSupport::Concern

  private

  def setup_sortable_client
    delete_cookie if params[:clear]
    @client_sorter = ClientSorter.new(@clients, current_user, params, cookie_filters)
    @sort_order = @client_sorter.sort_order
    @sort_column = @client_sorter.sort_column
    set_cookie
  end

  def delete_cookie
    cookies.delete(filter_cookie_name) if filter_cookie_name.present?
  end

  def set_cookie
    cookies[filter_cookie_name] = JSON.generate(@client_sorter.active_filters) if filter_cookie_name.present?
  end

  def cookie_filters
    return {} unless filter_cookie_name.present?

    cookies[filter_cookie_name] ? HashWithIndifferentAccess.new(JSON.parse(cookies[filter_cookie_name])) : {}
  end
end
