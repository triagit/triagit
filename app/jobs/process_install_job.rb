class ProcessInstallJob < ApplicationJob
  queue_as :default

  def perform(*args)
    return unless args.present?
    event = args[0]
    client = GithubClient.new_install_client event.payload[:id]
    repos = client.list_installation_repos
    repos.repositories.each do |repo|
      qrepo = Event.create! name: 'repo', ref: repo.full_name, payload: repo.to_hash
      ProcessRepoJob.perform_later qrepo
    end
  end
end
