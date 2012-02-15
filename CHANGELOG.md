## 0.1.2 \[ In Development \] \[ Branch: master \]

*   Ability to use render method to specify rendered page

    ```
      def index
        render 'hello/world', :layout => 'puffer_pages'
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