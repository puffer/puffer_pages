Fabricator(:page_part) do
  name { Forgery::LoremIpsum.word }
  body { Forgery::LoremIpsum.sentence }
end
