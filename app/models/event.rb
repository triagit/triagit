# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  repo_id    :integer
#  name       :string
#  ref        :string
#  payload    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_events_on_repo_id  (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Event < ApplicationRecord
  belongs_to :repo
  serialize :payload, JSONSerializer
end
