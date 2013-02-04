Fabricator(:page_part, class_name: :'puffer_pages/page_part') do
  name { Forgery::LoremIpsum.word }
  body { |attrs| "PagePart: `#{attrs[:name]}`" }
  if PufferPages.localize
    body_translations do
      (I18n.available_locales - [I18n.locale]).each_with_object({}) do |locale, result|
        result[locale] = Forgery::LoremIpsum.sentence(random: true)
      end
    end
  end
end

Fabricator(:main, from: :page_part) do
  name { PufferPages.primary_page_part_name }
end

Fabricator(:sidebar, from: :page_part) do
  name { 'sidebar' }
end
