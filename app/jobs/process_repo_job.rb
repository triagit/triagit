class ProcessRepoJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	return unless args.present?
  	event = args[0]
  	logger.info 'Processing repo', event: event
  end
end
