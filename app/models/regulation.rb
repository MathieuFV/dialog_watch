class Regulation < ApplicationRecord
  belongs_to :organization
  has_many :restrictions, dependent: :destroy

  scope :active, -> { where(active: true) }

  def permanent?
    restrictions.any? { |r| r.end_date.nil? }
  end

  def computed_type
    types = restrictions.map(&:restriction_type).uniq.compact
    return "Inconnu" if types.empty?
    types.size > 1 ? "Multi-type" : types.first
  end
end
