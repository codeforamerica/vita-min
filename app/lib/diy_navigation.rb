class DiyNavigation
  include ControllerNavigation

  FLOW = [
           Diy::FileYourselfController,
           # TODO: delete email controller
           Diy::EmailController,
           Diy::ContinueToFsaController
         ].freeze
end
