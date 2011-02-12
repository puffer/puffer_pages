Fabricator(:snippet) do
  name { Forgery::LoremIpsum.word }
  body { Forgery::LoremIpsum.sentence }
end
