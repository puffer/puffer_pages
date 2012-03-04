module PufferPages
  module Liquid
    class FileSystem < ::Liquid::BlankFileSystem

      def read_template_file template_path, context
        case template_type(template_path)
        when :snippet then
          template_path = template_path.gsub(/^snippets\//, '')
          snippet = ::Snippet.find_by_name(template_path)
          raise ::Liquid::FileSystemError, "No such snippet '#{template_path}' found" unless snippet
          snippet.body
        when :layout then
          template_path = template_path.gsub(/^layouts\//, '')
          layout = ::Layout.find_by_name(template_path)
          raise ::Liquid::FileSystemError, "No such layout '#{template_path}' found" unless layout
          layout.body
        when :page_part then
          page_part = context.registers[:page].part(template_path)
          raise ::Liquid::FileSystemError, "No such page_part '#{template_path}' found for current page" unless page_part
          page_part.body
        end
      end

      def template_type template_path
        return :snippet if template_path.start_with? 'snippets/'
        return :layout if template_path.start_with? 'layouts/'
        return :page_part
      end

    end
  end
end
