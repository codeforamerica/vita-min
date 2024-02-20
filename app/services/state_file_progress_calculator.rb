class StateFileProgressCalculator

  SECTION_MARKERS = []

  def initialize(navigator)
    @navigator = navigator
  end

  def get_progress(controller, current_controller)
    index = @navigator.controllers.index(controller)
    len = @navigator.controllers.length
    (index * 100.0 / len).round
  end
end
