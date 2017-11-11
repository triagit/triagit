module Github
  class CheckPrSizeJob < ApplicationJob
    queue_as :default

    # https://developer.github.com/v3/activity/events/types/#pullrequestevent
    WEBHOOK_EVENT_NAME = 'pull_request'
    WEBHOOK_EVENT_ACTIONS = ['opened', 'reopened', 'synchronize']

    def perform(*args)
      begin
        event = args[0]
        return unless valid?(event)
        rule_name = args[1]
        rule = event.repo.rules[:rules].find{ |r| r[:name] == rule_name }
        # TODO: Need more sophisticated rule validation
        # i.e. whether necessary parameters for a rule was given or not
        raise unless rule
      rescue => e
        return logger.error 'Invalid argument passed', args: args
      end
      logger.info self.class.name, event: event.name, repo: event.repo.ref, rule: rule_name
      process_rule event, rule
    end

    def valid?(event)
      return event && event.is_a?(Event) &&
        event.repo.service == Constants::GITHUB &&
        event.name == WEBHOOK_EVENT_NAME &&
        WEBHOOK_EVENT_ACTIONS.include?(event.payload[:action])
    end

    def process_rule(event, rule)
      repo = event.repo
      repo_owner, repo_name = repo.name.split('/')
      pr_number = event.payload[:pull_request][:number].to_i
      rules = rule[:options][:strategy]
      api_client = GithubClient.instance.new_repo_client(event.repo)
      files_count = api_client.pull_request_files(repo.ref, pr_number).count
      gql_client = Github::GithubClient.instance.new_graphql_client api_client
      res = gql_client.query self.class.pr_changes, variables: { owner: repo_owner, repo: repo_name, size: 50 }
      pr = res.data.repository.pull_requests.nodes.select { |node| node.number == pr_number }.first
      changes = pr.additions + pr.deletions
      reference, key = files_count >= changes ? [files_count, :files] : [changes, :lines]
      rulecat = rules.select { |r| r.has_key?(key) && reference <= r[key] }
      final_rule = rulecat.empty? ? rules.last : rulecat.first
      all_rule_labels = rules.collect { |r| r[:apply_label] if r[:apply_label].present? }.compact
      pr_diff_labels = pr.labels.nodes.collect { |l| l.name if all_rule_labels.include? l.name }.compact - [final_rule[:apply_label]]
      pr_diff_labels.each { |l| api_client.remove_label(repo.ref, pr_number, l) }
      api_client.add_labels_to_an_issue(repo.ref, pr_number, [final_rule[:apply_label]])
      api_client.add_comment(repo.ref, pr_number, final_rule[:add_comment]) if final_rule.has_key?(:add_comment)
    end

    def self.pr_changes
      @line_changes ||= Github::GithubClient.instance.new_graphql_query <<-'GRAPHQL'
      query($owner:String!, $repo:String!, $size:Int!) {
        repository(owner: $owner, name: $repo) {
          pullRequests(states: OPEN, first: $size, orderBy: {field: UPDATED_AT, direction: ASC}) {
            nodes {
              additions
              deletions
              number
              labels(first: $size) {
                nodes {
                  name
                }
              }
            }
          }
        }
      }
      GRAPHQL
    end
  end
end
