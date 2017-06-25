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
#
# Indexes
#
#  index_events_on_repo_id  (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
