class DiyNavigation
  include ControllerNavigation

  FLOW = [
           Diy::FileYourselfController,
           # TODO: delete email controller after this code has been live for a day
           Diy::EmailController,
           Diy::ContinueToFsaController
         ].freeze
end
