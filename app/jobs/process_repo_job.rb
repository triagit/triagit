class ProcessRepoJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	return unless args.present?
  	repo = args[0]
  	logger.info 'Processing repo', repo: repo
  end
end
