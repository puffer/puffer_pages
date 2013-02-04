module PufferPages
  module Liquid
    class FileSystem < ::Liquid::BlankFileSystem

      def read_template_file template_path, context
        source = case template_type(template_path)
        when :snippet then
          template_path = template_path.gsub(/^snippets\//, '')
          snippet = snippet(template_path)
          raise ::Liquid::FileSystemError,
            "No such snippet '#{template_path}' found" unless snippet
          snippet
        when :layout then
          template_path = template_path.gsub(/^layouts\//, '')
          layout = layout(template_path)
          raise ::Liquid::FileSystemError,
            "No such layout '#{template_path}' found" unless layout
          layout
        when :super then
          page_part = context[:processed]
          raise ::Liquid::FileSystemError,
            "Can not render super page_part outside the page_part context" unless page_part.is_a?(PufferPages::PagePart)
          parent_part = page_part.parent
          raise ::Liquid::FileSystemError,
            "No super page_part found for #{page_part.name}" unless parent_part
          parent_part
        when :page_part then
          page_part = context.registers[:page].inherited_page_part(template_path)
          raise ::Liquid::FileSystemError,
            "No such page_part '#{template_path}' found for current page" unless page_part
          page_part
        end

        source.respond_to?(:render) ? source : ::Liquid::Template.parse(source)
      end

      def template_type template_path
        return :super if template_path == :super
        return :layout if template_path.start_with? 'layouts/'
        return :snippet if template_path.start_with? 'snippets/'
        return :page_part
      end

      def snippet name
        @snippets_cache ||= {}
        @snippets_cache[name] ||= PufferPages::Snippet.find_snippet(name)
      end

      def layout name
        @layouts_cache ||= {}
        @layouts_cache[name] ||= PufferPages::Layout.find_layout(name)
      end

    end
  end
end
