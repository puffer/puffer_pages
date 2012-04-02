Fabricator(:layout) do
  name { Forgery::LoremIpsum.word }
  body { Forgery::LoremIpsum.sentence }
end

Fabricator(:foo_layout, :from => :layout) do
  name "foo_layout"
  body "foo_layout {{self.slug}}"
end

Fabricator(:bar_layout, :from => :layout) do
  name "bar_layout"
  body "bar_layout {{self.slug}}"
end
