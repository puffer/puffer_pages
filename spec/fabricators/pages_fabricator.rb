Fabricator(:page) do
  name { Forgery::LoremIpsum.sentence }
  slug ''
  title { Forgery::LoremIpsum.sentence }
  description { Forgery::LoremIpsum.sentence }
  keywords { Forgery::LoremIpsum.sentence }
  status {'published'}
end

Fabricator(:root, :from => :page) do
  slug ''
  layout_name 'foo_layout'
end
