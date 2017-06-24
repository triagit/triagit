# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  service    :string(2)
#  ref        :string
#  payload    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_ref      (ref) UNIQUE
#  index_users_on_service  (service)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
