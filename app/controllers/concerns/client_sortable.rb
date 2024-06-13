module ClientSortable
  extend ActiveSupport::Concern

  def self.included(base)
    base.helper_method :vita_partners_for_tagify
  end

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

  def vita_partners_for_tagify
    # This yields the vita partners in a format that the tagify js library can understand
    vita_partners = @client_sorter.active_filters[:vita_partners]
    return if vita_partners.blank?
    vita_partners = JSON.parse(vita_partners)
    result = vita_partners.map do |id|
      id = id[:id] if id.instance_of?(Hash)
      vita_partner = @vita_partners.find { |p| p.id == id }
      {
        id: vita_partner.id,
        name: vita_partner.name,
        parentName: vita_partner.parent_organization&.name,
        value: vita_partner.id
      }
    end
    result.to_json
  end
end
