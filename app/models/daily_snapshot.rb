class DailySnapshot < ApplicationRecord
    has_many :snapshot_events, dependent: :destroy
end
