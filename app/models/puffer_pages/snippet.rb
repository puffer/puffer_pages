class PufferPages::Snippet < ActiveRecord::Base
  self.abstract_class = true

  validates_presence_of :name
  validates_uniqueness_of :name
end
