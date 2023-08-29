module Navigation
  class DiyNavigation
    include ControllerNavigation

    FLOW = [
             Diy::FileYourselfController,
             Diy::ContinueToFsaController
           ].freeze
  end
end