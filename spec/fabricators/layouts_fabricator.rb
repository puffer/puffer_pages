Fabricator(:layout) do
  name { Forgery::LoremIpsum.word }
  body { Forgery::LoremIpsum.sentence }
end
