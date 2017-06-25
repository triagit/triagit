# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  service    :string(2)        not null
#  ref        :string           not null
#  payload    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_service          (service)
#  index_users_on_service_and_ref  (service,ref) UNIQUE
#

class User < ApplicationRecord
  serialize :payload, JSONSerializer
  has_many :account_users
  has_many :accounts, through: :account_users
end
