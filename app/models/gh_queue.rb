class GhQueue < ApplicationRecord
	validates :job, presence: true, inclusion: { in: %w(install repo issue pull) }
	validates :ref, presence: true
	serialize :payload, JSONSerializer
end
