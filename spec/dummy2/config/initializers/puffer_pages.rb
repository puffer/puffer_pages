# Use this to configure puffer pages
PufferPages.setup do |config|

  # Every pufer page has some page_parts, so the default page part
  # that renders by {% yield %} tag without any param has default
  # name `body`, but you can change it to `main` for example.
  # config.primary_page_part_name = 'main'

  # By default every page has location looks like `/about`,
  # `/about/team/`, `/about/team/richard`.
  # You can set this options and page location will be equal to
  # slug and have only one section, ex. `/about`, `/team`,
  # `/richard`. In this case every page should have unique slug.
  # config.single_section_page_path = true

end
