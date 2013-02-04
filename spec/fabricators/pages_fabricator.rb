Fabricator(:page, class_name: :'puffer_pages/page') do
  name { Forgery::LoremIpsum.sentence(random: true) }
  slug ''
  status {'published'}

  after_build do |page|
    page.page_parts.each do |page_part|
      if page_part.body == "PagePart: `#{page_part.name}`"
        page_part.body = "PagePart: `#{page_part.name}`, Page: `#{page.location}`"
      end
    end
  end
end

Fabricator(:root, from: :page) do
  slug ''
  layout_name 'application'
end

Fabricator(:foo_root, from: :page) do
  slug ''
  layout_name 'foo_layout'
end
