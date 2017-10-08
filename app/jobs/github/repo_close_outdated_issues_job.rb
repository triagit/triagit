module Github
  class RepoCloseOutdatedIssuesJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo)
        return logger.error 'Invalid argument passed', args: args
      end
      repo = args[0]
      labels = ["Inactive", "RIP"]
      logger.info self.class.name, repo: repo.name
      api_client = Github::GithubClient.instance.new_repo_client repo
      gql_client = Github::GithubClient.instance.new_graphql_client api_client
      repo_owner, repo_name = repo.name.split('/')
      res = gql_client.query self.class.outdated_query, variables: { owner: repo_owner, repo: repo_name, size: 50 }
      outdated_issues = res.data.repository.issues.nodes.select do |issue|
        outdated? issue
      end
      outdated_issues.each do |issue|
        api_client.add_labels_to_an_issue(repo.ref, issue.number, labels)
        api_client.close_issue(repo.ref, issue.number)
      end
    end

    private

    def outdated?(issue)
      now - Time.parse(issue.updated_at) > 2.minutes
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
