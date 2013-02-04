Fabricator(:layout, class_name: :'puffer_pages/layout') do
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

Fabricator(:application, from: :layout) do
  name { "application" }
end

Fabricator(:foo_layout, from: :layout) do
  name { "foo_layout" }
  body { "foo_layout {{self.slug}}" }
end

Fabricator(:bar_layout, from: :layout) do
  name { "bar_layout" }
  body { "bar_layout {{self.slug}}" }
end
