module Hub
  class ClientFilterForm < Form
    attr_accessor :sort_column, :sort_order, :_filtered_and_sorted_clients

    def filtered_and_sorted_clients(clients)
      clients = clients.after_consent
      clients.delegated_order(sort_column, sort_order)
    end

    def initialize(*args, **attributes)
      super(*args, **attributes)
      self.sort_column = %w[preferred_name updated_at locale].include?(sort_column) ? sort_column : "id"
      self.sort_order = sort_order == "desc" ? "desc" : "asc"
    end
  end
end
