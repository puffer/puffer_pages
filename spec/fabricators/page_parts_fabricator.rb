Fabricator(:page_part) do
  name { Forgery::LoremIpsum.word }
  body { Forgery::LoremIpsum.sentence }
end

Fabricator(:main, :from => :page_part) do
  name PufferPages.primary_page_part_name
  body { Forgery::LoremIpsum.sentence }
end
