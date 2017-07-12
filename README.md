# triagit [![staging](https://gitlab.com/triagit/triagit/badges/master/build.svg)](https://gitlab.com/triagit/triagit/commits/master)

## Rules

* close/flag outdated issue
* close/flag outdated pr
* delete outdated/PR-merged branches
* require signed commits
* require lgtm/approval from N accounts
* commmit message must be of given format
* must have signed CLA
* auto-assign label upon creation
* auto-assign label upon diff paths
* auto-assign reviewer upon creation
* diff size must be less than X
* must have a label (e.g. Ready for release, etc)
* must have label for certain diff paths (e.g. Migration approved)
* move project boards based on labels
* auto approve PRs from certain teams/users
* auto-assign priority based on number of upvotes/+1s
* lock issue/PR comments based on # of comments, to prevent spam

## Other Requirements

* Automatic organization-wide enforced rules
* Dashboard with activities (subsequently users, roles, permissions)
* Good audit logging
  * Repo/Rule -> See recent events and actions
  * Filter events -> some form of indexed tags/filters/facets
  * Two way traceability, source -> action, action -> source
* Testing
  * Lots of mocks and data-driven test cases
  * Few options for e2e testing, cannot be done on-demand
  * Maybe can do regression testing, but lots of seeding required, restricted environment, cannot fake usernames/timestamps and so on

## Technical Thought Process

* Why Ruby/Rails?
  - Official github octokit.rb client, first-class citizen
  - Automatic pagination with handling of rate limits, built-in ETag and caching, etc
  - ActiveJob, resque, UI dashboard, essential for background jobs
  - ActiveRecord with transparent and programmatic caching
  - And rest of everything we normally need (aka can be done with any language but easily integrated) - ORM, asset pipeline, user sign in oauth libraries, templating, etc etc
  - Ruby response time is 160ms, Equally similar NodeJS response time is 130ms on heroku (mailcheck vs triagit), possible to optimize within and get <100ms response times with Ruby as well, so no REAL performance benefit moving to node, maybe only concurrency benefit, but if we don't do much stuff concurrently and queue up, then don't have to bother as well
  - Given all the above, good choice to begin and sustain scale

* But let's keep in mind,
  - GitHub, User login, Website, etc - are all developed as individual pieces with separate namespaces with *nothing shared* architecture, except the bare minimum database models
  - The bare minimum models must NOT become fat models, use activeattr/MVVM styles for additional logic
  - Always should be straight forward to separate out individual parts into separate apps, duplication is better than premature sharing
  - And we know, Ruby is not screaming fast, but in the beginning horizontal scaling is good enough, and immediately adding all requests into a queue and processing them later with fault tolerance works great even without scale

## Rules Engine Thought Process

- docs, examples, for a rule, etc
- custom attributes for each rule
  - since 30days to close, label to apply when closing, etc
- rules process/respond to events
  - treat everything as an event, even a simple cron trigger
- no cross-event interactions to begin with
  - unidirectional, fail with link to sign CLA, CLA signed, passes
- same event can be processed by multiple rules
  - e.g. PR checks, cron triggers, etc
- fan-in/fan-out?
  - multiple rules have to update a single PR
  - what's the unit of exection?
- streaming
  - cannot buffer in-memory, cannot use in-memory map/reduce per event
  - has to be streaming requests and responses
  - cannot fan-in, can only fan-out
- unit of execution
  - PR check: 1 trigger, 1 target (PR), multiple rules
    - needs context: pr/issue/entity (whole hook event is context)
    - whole event is re-queued if failed
    - "Details" page when PR is red? or each rule as PR check? or comment as UI sonarqube style?
  - Scheduled jobs: 1 trigger, 1 rule, multiple targets (issues, prs, branches, etc)
    - Breaking down scheduled jobs, how to?
    - retry policy - cron event is acked, but each intermediate event can be retried individually
  - Other webhooks: decide later
- queuing
  - event can have an immediate action (yellow PR)
  - and also a delayed/queued action (red/green PR)
  - two classes or one class accepting two events?
  - upon receiving webhook - mark PR as yellow, and then proceed to rest
  - CONFLICT: if each rule is a yellow flag, then what to mark as yellow here?
- throttling, retrying
  - based on payment plans, github call limits, rule/repo priority, etc
- usage tracking, auditing
  - non-retryable execution errors must be displayed in account UI
- visual editing/updating, validation, linting, ser/deser
- higher context, metadata
  - slack channel, total rules per repo/account
  - repo admins, team admins, etc
- deprecation, versioning
- speed, constant ser/deser, etc
- memory
  - updating same comment over and over again
  - sending a notification only for first time, etc

```
RulesContext
  new(repo)
    read rules.yaml from repository and return Rules object
    cache Rules object if necessary
    fail if any rule is not applicable for this repo or malformed rules.yaml
  repo_id: Repo id
  rev: revision
  rules: arr[Rule]
  process(event)

Rule
  GitHub::CloseOutdatedIssues
  GitHub::CloseOutdatedPrs
  ...
  service::inflection
    new(ctx, attrs={ since: 30, ... }) -> fails if rule is not applicable to repo, etc
    execute(event) -> manipulates actions

Missing piece: Action
  fan-in/fan-out
  multiple rules contributing to a PR update
  handling failure-in-middle
  Event > Rules > Action
  if Actions are also Events, makes things complicated?
```

## yaml syntax (change based on requirements above)

```
rules:
  close_outdated_prs:
    days: 10
    ignore_labels: a, b, c
    apply_label: flagged
  close_outdated_issues:
    older: 10d
    ignore_labels: a, b, c
    apply_label: flagged
  delete_merged_branches:
    days: 10
  require_signed_commits:
    ignore_authors: @team, @handle, comma separated list
  auto_approve:
    authors: @team, @handle, comma separated list
  require_commit_message_format:
    regex: a regex here
  require_cla:
    cla_file: CLA filename, with or without full git url
```

## DB Models Overview

```
User: email, handle
Account: email, billing, installation, type (github/gitlab/etc)
  AccountUser: account <> user
  Token (ephemeral)
  Repo: rules, settings, ...
    Event
```

## Flow

webhook
  sanity checks - org/repo, active billing/installation, etc
  save webhook event
  queue webhook job
  if PR? mark PR as yellow?

webhook job
  issue? pr?



## TODO

* What if same git repo in multiple integrations/accounts?
  * +if using soft deletes (i.e. account status=inactive/blocked)
* User installs sync - Cleaning up removed/phantom installs
