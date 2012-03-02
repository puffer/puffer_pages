## 0.1.2 \[ In Development \] \[ Branch: master \]

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

    If `hello/world` page body: '{{count}}'
    This action will produce '42'

*   Removed attributes tags. Now attributes are rendered with standart
    variable call. I.e. `{{ page.title }}` - title here will be rendered
    but not just inserted.

## 0.1.1

### New features

*   Updated codemirror to 2.2 version.

*   Custom component renamed to Codemirror component.

*   Added buttons panel to Codemirror editor.

*   Added fullscreen feature to Codemirror.

*   Added Liquid overlay to Codemirror.

*   Rails 3.2 compatible.