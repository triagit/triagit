class ProcessInstallJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	return unless args.present?
  	queue = args[0]
  	client = GhClient.new_install_client queue.payload[:id]
  	repos = client.list_installation_repos
  	repos[:repositories].each do |repo|
      qrepo = GhQueue.create! job: 'repo', ref: repo.full_name, payload: repo.to_hash
  		ProcessRepoJob.perform_later qrepo
  	end
  end
end
