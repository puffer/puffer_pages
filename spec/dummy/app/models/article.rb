class Article < ActiveRecord::Base

  validates :title, :presence => true
  validates :slug, :presence => true, :uniqueness => true

  before_validation :sluggify

  def sluggify
    self.slug = title.parameterize
  end

  def to_param
    slug
  end

end
