at_exit do
  executor = Concurrent.global_io_executor
  executor.shutdown
  executor.kill unless executor.wait_for_termination(30.seconds)
end
