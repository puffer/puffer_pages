## 0.1.2 \[ In Development \] \[ Branch: master \]

### New features

*   Added `super` tag, which acts inside page parts and
    renders content of parent page part like include.

*   Added new tags `snippet` and `layout`. They acts like
    a short-cuts to `include`. I.e. `{% snippet 'hello' %}`
    is the same is `{% include 'snippets/hello' %}`. Both
    tags supports additional parameters as `include`

*   Removed `root` page object from context.

*   All template assigns, not respondable to `to_liquid` are joined
    to context registers, so can be used from drops.

*   Ability to use render method to specify rendered page

    ```
      def index
        render 'hello/world', :layout => 'puffer_pages'
      end
    ```

    This example will render page with 'hello/world' location.

*   All controller instance variable assigns will be transferret
    to liquid as drops if they are respond to `to_liquid`

    ```
      def index
        @answer = 42
        render 'hello/world', :layout => 'puffer_pages'
      end
    ```

    If `hello/world` page body: `{{count}}`
    This action will produce `42`

## 0.1.1

### New features

*   Updated codemirror to 2.2 version.

*   Custom component renamed to Codemirror component.

*   Added buttons panel to Codemirror editor.

*   Added fullscreen feature to Codemirror.

*   Added Liquid overlay to Codemirror.

*   Rails 3.2 compatible.