class ProcessInstallationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	logger.info 'Processing installations'
    installations = GithubClient.new_app_client.find_installations
    installations.each do |install|
    	qinstall = Event.create! name: 'install', ref: install.id, payload: install.to_hash
    	ProcessInstallJob.perform_later qinstall
    end
  end
end
