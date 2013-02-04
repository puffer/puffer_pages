Fabricator(:snippet, class_name: :'puffer_pages/snippet') do
  name { Forgery::LoremIpsum.word(random: true) }
  body { Forgery::LoremIpsum.sentence(random: true) }
  if PufferPages.localize
    body_translations do
      (I18n.available_locales - [I18n.locale]).each_with_object({}) do |locale, result|
        result[locale] = Forgery::LoremIpsum.sentence(random: true)
      end
    end
  end
end

Fabricator(:custom, from: :snippet) do
  name { "custom" }
end
