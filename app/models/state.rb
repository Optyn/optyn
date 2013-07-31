class State < ActiveRecord::Base
  attr_accessible :name, :abbreviation

  scope :by_abbreviation, ->(abbr) { where(["states.abbreviation ILIKE :abbr", {abbr: abbr}]) }

  def self.for_abbreviation(abbr)
    by_abbreviation(abbr).first
  end
end
