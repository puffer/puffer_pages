Fabricator(:page) do
  name { Forgery::LoremIpsum.sentence }
  slug '/'
  title { Forgery::LoremIpsum.sentence }
  description { Forgery::LoremIpsum.sentence }
  keywords { Forgery::LoremIpsum.sentence }
end
