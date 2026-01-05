class Organization < ApplicationRecord
    has_many :regulations, dependent: :destroy
end
