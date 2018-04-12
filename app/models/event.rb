# == Schema Information
#
# Table name: events
#
#  id         :uuid             not null, primary key
#  repo_id    :uuid
#  name       :string           not null
#  ref        :string           not null
#  payload    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :integer          default(0), not null
#
# Indexes
#
#  index_events_on_repo_id  (repo_id)
#  index_events_on_status   (status)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Event < ApplicationRecord
  belongs_to :repo
  serialize :payload, JSONSerializer
  scope :active, -> { where status: Constants::STATUS_ACTIVE }

  validates :repo, presence: true
end
