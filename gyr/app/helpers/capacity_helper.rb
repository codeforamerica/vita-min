module CapacityHelper
  # expects a Capacity struct
  def display_capacity(capacity)
    "#{capacity.current_count || '-'} / #{capacity.total_capacity || "-"}"
  end
end