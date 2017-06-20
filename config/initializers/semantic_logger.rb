Rails.application.configure do
  config.rails_semantic_logger.quiet_assets = true
  config.rails_semantic_logger.add_file_appender = false
  if Rails.env.test? || Rails.env.development?
    SemanticLogger.add_appender(io: $stdout, level: :debug)
  else
    SemanticLogger.add_appender(io: $stdout, formatter: :json, level: :info)
  end
end
