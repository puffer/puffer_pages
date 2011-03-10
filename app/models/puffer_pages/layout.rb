class PufferPages::Layout < ActiveRecord::Base
  self.abstract_class = true

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :pages, :class_name => '::Page'
end
