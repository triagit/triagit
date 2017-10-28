module Constants
  SERVICE_NAME = (ENV['SERVICE_NAME'] || 'triagit-dev').freeze

  GITHUB = 'gh'.freeze

  PLAN_FREE_0 = 'f0'.freeze

  STATUS_ACTIVE = 0
  STATUS_INACTIVE = 1
end
