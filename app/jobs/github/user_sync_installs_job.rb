module Github
  class UserSyncInstallsJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(User) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      user = args[0]
      logger.info self.class.name, user: user.id, service: user.service
      client = GithubClient.instance.new_user_client(user)
      opts = client.ensure_api_media_type(:integrations, {})
      before_sync_timestamp = DateTime.now
      gh_installs = client.paginate '/user/installations', opts
      gh_installs.installations.each do |gh_install|
        sync_gh_install client, user, gh_install
      end

      # Remove old/revoked access accounts
      AccountUser.where(user: user).where('updated_at < ?', before_sync_timestamp).delete_all
    end

    protected

    def sync_gh_install(client, user, gh_install)
      logger.info 'sync_gh_install', user: user.id, install: gh_install.id
      before_sync_timestamp = DateTime.now
      opts = client.ensure_api_media_type(:integrations, {})
      account = Account.find_or_initialize_by(
        service: Constants::GITHUB, ref: gh_install.id
      )
      account.name = gh_install.account.login
      account.payload = gh_install.to_h
      account.token ||= SecureRandom.uuid
      account.plan ||= Constants::PLAN_FREE_0
      account.status = Constants::STATUS_ACTIVE
      account.updated_at = DateTime.now
      account.save!

      gh_repos = client.paginate "/user/installations/#{gh_install.id}/repositories", opts
      gh_repos.repositories.each do |gh_repo|
        sync_gh_repo client, user, account, gh_repo
      end

      # Remove old/deleted repos
      account.repos.where('updated_at < ?', before_sync_timestamp).update_all(status: Constants::STATUS_INACTIVE)
      sync_user_account user, account
    end

    def sync_user_account(user, account)
      account_user = AccountUser.find_or_initialize_by(user: user, account: account)
      account_user.updated_at = DateTime.now
      account_user.save!
    end

    def sync_gh_repo(client, user, account, gh_repo)
      # TODO: Handle repository renames
      logger.info 'sync_gh_repo', user: user.id, account: account.ref, repo: gh_repo.full_name
      repo = Repo.find_or_initialize_by(
        service: Constants::GITHUB, account: account, ref: gh_repo.full_name
      )

      repo.name = gh_repo.full_name
      repo.ref = gh_repo.full_name
      repo.payload = gh_repo.to_h
      repo.status = Constants::STATUS_ACTIVE
      repo.updated_at = DateTime.now
      repo.save!

      RepoSyncJob.perform_later repo
      repo
    end
  end
end
