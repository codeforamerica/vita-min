class DiyNavigation
  include ControllerNavigation

  FLOW = [
           Diy::FileYourselfController,
           Diy::EmailController,
           Diy::ContinueToFsaController
         ].freeze
end
