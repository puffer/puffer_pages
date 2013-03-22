## 0.6.0 \[ In Development \] \[ Branch: master \]

### New features

*   New `cache` tag. Fragment caching for puffer pages.

    Options:
    - `config.puffer_pages.perform_caching` - enable or disable caching at all,
    takes `config.action_controller.perform_caching` value by default
    - `config.puffer_pages.cache_store`. Acts the same way as rails
    `config.cache_store`. Takes it's value by default.

    Usage:

    `cache ['additional_key1', 'additional_key2', ...][, expires_in: expiration]`
    where `expiration` is a string with format:
    - `10`, `10s` - 10 seconds
    - `7m` - 7 minutes
    - `5h` - 5 hours
    - `3d` - 3 days
    - `3d 4h 19m` - combination

    Examples:
    - `{% cache %}Hello!{% endcache %}`.
    - `{% cache 'some_key', expires_in: '1h' %}Hello!{% endcache %}`.

*   Added `PufferPages::Rspec` module. Just `require 'puffer_pages/rspec'` in your
    `spec_helper` and get all of the puffer_pages rspec features.

*   PufferPages actions now respects RSpec's `render_views` in `ControllerExampleGroup`.
    Renderer renders mock page and compairing only locations of rendered and specified pages,
    so you will not get `PufferPages::MissedPage` even if page does not exist in database,
    but can be shure that proper page renders with `should render_page`.

### Infrastructure changes

*   `PufferPages::MissedPage` instead of `PufferPages::LayoutMissing`.

*   Now PufferPages rendering errors raises on a controller level instead of model methods.

## 0.5.1

### New features

*   Added abulity to cancel puffer_page rendering with `render puffer_page: false` option.

*   Added pluralization support to liquid backend (Exoth).

*   Added `image` liquid tag - alias to image_path helper (andrewgr).

## 0.5.0

### New features

*   PufferPages is mountable engine now, so `mount PufferPages::Engine => '/'`

*   `scope` tag. Just creates variables scope inside its block.

*   Origins - full import-export system. Just add your remote server and syncronize all the pages.

*   PagePart handlers - now page part can be a hash.

*   First rspec matcher - `render_page`.

*   `title`, `description`, and `keywords` fields are remove, use page_parts.

*   Move from usual ids to uuids with `activeuuid` gem.

*   Templates localization with `globalize3` gem.

*   `locales` to store page locales + I18n backend. Locales are inheritable.

*   `t` or `translate` tag. Works similar to `t` ActionView helper. Translation keys
    started with `.` (i.e `{% t '.hello' %}`) are scoped. For layouts it will be
    `layouts.layout_name.hello`, for snippets - `snippets.snippet_name.hello` and for
    pages - `puffer_pages.full.page.location.page_parts.page_part_name.hello`
    but for pages it looks for default values:
    - `puffer_pages.full.page.location.hello`
    - `puffer_pages.full.page.page_parts.page_part_name.hello`
    - `puffer_pages.full.page.hello`
    - `puffer_pages.full.page_parts.page_part_name.hello`
    - `puffer_pages.full.hello`
    - `puffer_pages.page_parts.page_part_name.hello`
    - `puffer_pages.hello`

*   `config.puffer_pages.raise_errors = true` in any environment config file makes
    liquid templates errors raisable.

*   `render` tag. Acts same as rails <%= render %>

*   `url` and `path` tags

*   `array` tag:

    ```
      {% array arr = 'one', 2, variable %}
    ```

    will create array named `arr` with 3 items = ['one', 2, 'variable_content']

*   `javascript_tag` helper.

    ```
      {% javascript %}
        var i = '';
      {% endjavascript %}
    ```

*   `{% csrf_meta_tags %}` helper tag.

*   The new `puffer_pages` method for controller

    ```
      class SomeController < ActionController::Base
        # takes `:only`, `:except` and `:scope` options
        puffer_pages :only => :index

        def index
        end
      end
    ```

    `:scope` option is a symbol - method name, or proc.
    `:scope` adds a scope to Page query, which might be useful
    for i.e. subdomains or locale scoping since Page model can
    have more than one root page.

*   The only way to declare puffer_page rendering
    `render puffer_page: PufferPages::Page.first` or
    `render puffer_page: 'some/path'`.

*   Current controller now available from context.registers[:controller]
    It is useful for using url helpers in drops.

*   Added `super` tag, which acts inside page parts and
    renders content of parent page part like include.

*   Added new tags `snippet` and `layout`. They acts like
    a short-cuts to `include`. I.e. `{% snippet 'hello' %}`
    is the same is `{% include 'snippets/hello' %}`. Both
    tags supports additional parameters as `include`

*   Removed `root` page object from context.

*   All template assigns are joined to context registers,
    so can be used from drops.

*   All controller instance variable assigns will be transferret
    to liquid as drops if they are respond to `to_liquid`

    ```
      def index
        @answer = 42
        render puffer_page: 'hello/world'
      end
    ```

    If `hello/world` page body: `{{count}}`
    This action will produce `42`

*   Ability to use render method to specify rendered page

    ```
      def index
        render puffer_page: 'hello/world'
      end
    ```

    This example will render page with 'hello/world' location.

## 0.1.1

### New features

*   Updated codemirror to 2.2 version.

*   Custom component renamed to Codemirror component.

*   Added buttons panel to Codemirror editor.

*   Added fullscreen feature to Codemirror.

*   Added Liquid overlay to Codemirror.

*   Rails 3.2 compatible.