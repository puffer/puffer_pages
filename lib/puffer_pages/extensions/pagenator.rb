module PufferPages
  module Extensions
    module Pagenator # There is no error in module name
      extend ActiveSupport::Concern

      included do
        class_attribute :_puffer_pages_options
        self._puffer_pages_options = {:pagenated => false}
      end

      module ClassMethods
        def inherited(klass)
          super
          klass._puffer_pages_options = _puffer_pages_options.dup
        end

        def puffer_pages options = {}
          _puffer_pages_options[:pagenated] = true
          _puffer_pages_options[:only] = Array.wrap(options[:only]).map(&:to_s).presence
          _puffer_pages_options[:except] = Array.wrap(options[:except]).map(&:to_s).presence
          _puffer_pages_options[:scope] = options[:scope]
        end
      end

      def _normalize_options options
        super
        if options[:puffer_page] || (options[:puffer_page] != false && _puffer_pages_action?)
          scope = options[:puffer_scope].presence || _puffer_pages_options[:scope].presence
          page = options.values_at(:puffer_page, :partial, :action, :file).delete_if(&:blank?).first
          options[:puffer_page] = _puffer_pages_template(page, scope)
          options[:layout] = 'puffer_page'
        end
      end

    private

      def _puffer_pages_action?
        if only = _puffer_pages_options[:only]
          only.include?(action_name)
        elsif except = _puffer_pages_options[:except]
          !except.include?(action_name)
        else
          _puffer_pages_options[:pagenated]
        end
      end

      def _puffer_pages_template suggest, scope = nil
        return suggest if suggest.is_a?(PufferPages::Page)

        scope = case scope
        when Proc
          scope.call(self)
        when String, Symbol
          send scope
        else
          scope
        end

        PufferPages::Page.controller_scope(scope).find_view_page(
          suggest.presence || request.path_info,
          :formats => lookup_context.formats
        )
      end

    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::Pagenator
