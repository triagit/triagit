module Github
  class RepoCloseOutdatedIssuesJob < ApplicationJob
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
      issue_comment = rule[:options][:add_comment] rescue ""
      api_client = Github::GithubClient.instance.new_repo_client repo
      gql_client = Github::GithubClient.instance.new_graphql_client api_client
      repo_owner, repo_name = repo.name.split('/')
      res = gql_client.query self.class.outdated_query, variables: { owner: repo_owner, repo: repo_name, size: 50 }
      outdated_issues = res.data.repository.issues.nodes.select do |issue|
        outdated? rule, issue
      end
      outdated_issues.each do |issue|
        api_client.add_labels_to_an_issue(repo.ref, issue.number, labels)
        api_client.close_issue(repo.ref, issue.number)
        api_client.add_comment(repo.ref, issue.number, issue_comment)
      end
    end

    private

    def outdated?(rule, issue)
      oldest = ActiveSupport::Duration.parse(rule[:options][:older_than] || 'P1Y').ago
      Time.parse(issue.updated_at) < oldest
    end

    def now
      @now ||= Time.zone.now
    end

    def self.outdated_query
      @outdated_query ||= Github::GithubClient.instance.new_graphql_query <<-'GRAPHQL'
        query($owner:String!, $repo:String!, $size:Int!, $after:String) {
          repository(owner: $owner, name: $repo) {
            issues(states:OPEN, first: $size, after:$after, orderBy: {field:UPDATED_AT, direction: ASC}) {
              totalCount
              pageInfo {
                hasNextPage
                endCursor
              }
              nodes {
                number
                createdAt
                updatedAt
                url
                author {
                  login
                }
                labels(first:20) {
                  nodes {
                    name
                  }
                }
                milestone {
                  state
                  dueOn
                }
              }
            }
          }
        }
      GRAPHQL
    end
  end
end
