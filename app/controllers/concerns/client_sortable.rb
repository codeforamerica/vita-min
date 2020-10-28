module ClientSortable
  def setup_sortable_client
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : "desc"
  end

  def clients_sort_column
    %w[preferred_name id updated_at locale].include?(params[:column]) ? params[:column] : "id"
  end
end