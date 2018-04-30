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
#  status     :integer          default(0), not null
#
# Indexes
#
#  index_users_on_service          (service)
#  index_users_on_service_and_ref  (service,ref) UNIQUE
#  index_users_on_status           (status)
#

class User < ApplicationRecord
  GITHUB_SUPER_ADMINS = ENV['GITHUB_SUPER_ADMINS'].split(',')

  serialize :payload, JSONSerializer
  has_many :account_users
  has_many :accounts, through: :account_users
  scope :active, -> { where status: Constants::STATUS_ACTIVE }

  def display_name
    "#{service}/#{name}"
  end

  def superadmin?
    service == Constants::GITHUB && GITHUB_SUPER_ADMINS.include?(name)
  end
end
