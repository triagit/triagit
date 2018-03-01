Rails.application.configure do
  STDOUT.sync = true
  config.rails_semantic_logger.quiet_assets = true
  config.rails_semantic_logger.add_file_appender = false
  if Rails.env.test? || Rails.env.development?
    SemanticLogger.add_appender(io: STDOUT, level: :debug)
  else
    SemanticLogger.add_appender(io: STDOUT, formatter: :one_line, level: :info)
  end
end
