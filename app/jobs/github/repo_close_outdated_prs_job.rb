module Github
  class RepoCloseOutdatedPrsJob < ApplicationJob
    queue_as :default

    def perform(*args)
      begin
        repo = args[0]
        rule_name = args[1]
        logger.info self.class.name, repo: repo.name, rule: rule_name
        rule = repo.rules[:rules].find{ |r| r[:name] == rule_name } rescue nil
      rescue => e
        return logger.error 'Invalid argument passed', args: args
      end

      labels = rule[:options][:apply_labels] rescue []
      pr_comment = rule[:options][:add_comment] rescue ""
      api_client = Github::GithubClient.instance.new_repo_client repo
      gql_client = Github::GithubClient.instance.new_graphql_client api_client
      repo_owner, repo_name = repo.name.split('/')
      res = gql_client.query self.class.outdated_pr_query, variables: { owner: repo_owner, repo: repo_name, size: 50 }
      outdated_prs = res.data.repository.pull_requests.nodes.select do |pr|
        outdated? rule, pr
      end
      outdated_prs.each do |pr|
        # api_client.close_issue(repo.ref, issue.number)
        api_client.add_comment(repo.ref, pr.number, pr_comment) unless pr_comment.empty?
        api_client.close_pull_request(repo.ref, pr.number)
      end
    end

    private

    def outdated?(rule, pr)
      oldest = ActiveSupport::Duration.parse(rule[:options][:older_than] || 'P1Y').ago
      Time.parse(pr.updated_at) < oldest
    end

    def now
      @now ||= Time.zone.now
    end

    def self.outdated_pr_query
      @outdated_query ||= Github::GithubClient.instance.new_graphql_query <<-'GRAPHQL'
        query($owner:String!, $repo:String!, $size:Int!, $after:String) {
          repository(owner: $owner, name: $repo) {
            pullRequests(states:OPEN, first: $size, after:$after, orderBy: {field:UPDATED_AT, direction: ASC}) {
              nodes {
                number
                createdAt
                updatedAt
                url
                author {
                  login
                }
              }
            }
          }
        }
      GRAPHQL
    end
  end
end
