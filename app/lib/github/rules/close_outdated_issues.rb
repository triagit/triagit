module Github
  module Rules
    class CloseOutdatedIssues
      def execute(repo)
        Rails.logger.info 'CloseOutdatedIssues', repo: repo.ref
        client = Github::GithubClient.new_repo_client repo
        res = client.list_issues(repo.ref, state: "open", sort: "updated", direction: "asc")
        now = Time.zone.now
        outdated_issues = res.select do |issue|
          is_outdated? client, repo, issue, now
        end
        outdated_issues.each do |issue|
          client.close_issue(repo.ref, issue.number)
        end
      end

      private

      def is_outdated?(client, repo, issue, now)
        outdated = (now - issue.updated_at) > 15.minutes
      end
    end
  end
end
