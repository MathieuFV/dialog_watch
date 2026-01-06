class SnapshotEvent < ApplicationRecord
  belongs_to :daily_snapshot
  belongs_to :organization
  belongs_to :regulation, optional: true
end
