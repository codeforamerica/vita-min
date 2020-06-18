def track_progress
  @current_progress = find(".progress-indicator__percentage").text.to_i
end