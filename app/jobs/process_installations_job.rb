class ProcessInstallationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	logger.info 'Processing installations'
    installations = GhClient.new_app_client.find_installations
    installations.each do |i|
    	queue = GhQueue.create!(job: 'install', ref: i.id, payload: i.to_hash)
    	ProcessInstallJob.perform_later queue
    end
  end
end
