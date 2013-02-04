Fabricator(:article) do
  title { Forgery::LoremIpsum.word(random: true) }
  body { Forgery::LoremIpsum.sentence(random: true) }
end
