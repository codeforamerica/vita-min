##
# temporarily changes the Rails environment
def with_environment(env_name)
  prev = Rails.env
  Rails.env = env_name

  yield

ensure
  Rails.env = prev
end