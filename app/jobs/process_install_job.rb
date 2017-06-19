class ProcessInstallJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	return unless args.present?
  	queue = args[0]
  	client = GhClient.new_install_client(queue.payload[:id])
  	repos = client.list_installation_repos
  	repos.each do |repo|
  		logger.info 'Processing repo', repo: repo
  	end
  end
end
