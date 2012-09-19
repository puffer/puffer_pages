//= require puffer/right-tabs-src
//= require puffer/codemirror
//= require puffer/multiplex
//= require puffer/codemirror/xml
//= require puffer/codemirror/javascript
//= require puffer/codemirror/css
//= require_tree ./codemirror

Tabs.include({
  initialize: function(element, options) {
    this.$super(element, options);
    this.buildAddButton();
  },

  buildAddButton: function() {
    if (isFunction(this.options.addButton)) {
      this.addButton = $E('a', {'class': 'rui-tabs-tab rui-tabs-add', 'html': '<a href="#">+</a>'}).insertTo(this.tabsList);
      this.addButton.onClick(this.options.addButton.bind(this));
      this.onAdd(function(event) {
        this.addButton.insertTo(this.tabsList);
      });
    }
  },

  scrollTo: function(scroll) {
    // checking the constraints
    var available_width = this.scroller.size().x;
    if (this.addButton) {
      var addButtonWidth = this.addButton.dimensions().width;
    } else {
      var addButtonWidth = 0;
    }
    var overall_width   = this.tabs.map('width').sum() + addButtonWidth;

    if (scroll < (available_width - overall_width)) {
      scroll = available_width - overall_width;
    }
    if (scroll > 0) { scroll = 0; }

    // applying the scroll
    this.tabsList.morph({left: scroll+'px'}, {duration: this.options.scrollDuration});

    this.checkScrollButtons(overall_width, available_width, scroll);
  }
});

Tabs.Tab.include({
  initialize: function(element, main) {
    this.$super(element, main);
    if (main.options.disablable) {
      this.link.insert($E('div', {
        'class': 'rui-tabs-tab-close-icon', 'html': '&times;'
      }).onClick(function(event) {
        if (this.main.enabled().length > 1) {
          if (this.current()) {
            var enabled = this.main.enabled();
            var sibling = enabled[enabled.indexOf(this) + 1] || enabled[enabled.indexOf(this)-1];

            if (sibling) {
              sibling.select();
            }
          }
          this.disable();
        }
        event.stop();
      }.bind(this)));
    }
  }
});

var page_part_tab_select = function(event) {
  var inner_tabs = event.target.panel.find('.rui-tabs,*[data-tabs]').first();
  if (inner_tabs instanceof Tabs)
    inner_tabs.current().select();

  var textarea = event.target.panel.first('textarea[data-codemirror]');
  if (textarea && textarea.codemirror) {
    textarea.codemirror.refresh();
  }
}

var page_part_tab_add = function(event) {
  var _this = this;

  new Dialog.Prompt({label: 'Enter new page part name'}).onOk(function() {
    var value = this.input.value();
    if (!value.blank()) {
      _this.add(value);
      var tab = _this.tabs.last();
      tab.panel.data('name', value);
      fill_new_tab(tab);
      tab.select();

      Tabs.rescan();
      init_codemirrors();
      this.hide();
    }
  }).show();
  event.stop();
}

var page_part_tab_remove = function(event) {
  save_destroy_marks(event.target.panel);
}

var page_part_locale_select = function(event) {
  if (!event.target.enabled())
    event.target.enable();
  if (!event.target.current())
    event.target.select();

  if (event.target.panel.html().blank())
    fill_new_tab(event.target);

  var textarea = event.target.panel.first('textarea[data-codemirror]');
  if (textarea && textarea.codemirror) {
    textarea.codemirror.refresh();
  }
}

var page_part_locale_enable = function(event) {
  fill_new_tab(event.target);
}

var page_part_locale_disable = function(event) {
  save_destroy_marks(event.target.panel);
  event.target.panel.update();
}

var fill_new_tab = function(tab) {
  var new_id = new Date().getTime();
  if (tab.main.data('new-panel'))
    tab.panel.update(tab.main.data('new-panel').replace(new RegExp(tab.main.data('new-panel-variable'), 'g'), new_id));

  var name_input = tab.panel.first('[data-acts="name"]');
  var name_panel = tab.panel.first().parent('[data-name]');
  if (name_input && name_panel) {
    name_input.value(name_panel.data('name'));
  }

  var locale_input = tab.panel.first('[data-acts="locale"]');
  var locale = tab.data('locale');
  if (locale_input && locale) {
    locale_input.value(locale);
  }

  init_codemirrors();
}

var save_destroy_marks = function(scope) {
  var form = scope.tab.main.parent('form');
  scope.find('[data-acts="destroy"]').each(function(destroy_mark) {
    var page_part_param = destroy_mark.siblings('[data-acts="id"]').first();
    if (page_part_param) {
      form.append(destroy_mark.value('true'));
      form.append(page_part_param);
    }
  });
}

var init_codemirror = function(textarea) {
  if (!textarea.codemirror) {
    var codemirror = CodeMirror.fromTextArea(textarea._, {
      mode: 'liquid-mixed',
      lineNumbers: true,
      lineWrapping: true,
      matchBrackets: true,
      tabSize: 2,
      extraKeys: {
        "Tab": "indentMore",
        "Shift-Tab": "indentLess",
        "Esc": codemirror_fullscreen,
        "Alt-Enter": codemirror_fullscreen
      }
    });

    textarea.codemirror = codemirror;
    codemirror.buttons = textarea.prev('.codemirror_buttons');
  }
}

var init_codemirrors = function() {
  $$('textarea[data-codemirror]').each(init_codemirror);
}

$(document).onReady(function() {
  init_codemirrors();
});

$(document).on('data:sending', function() {
  $$('textarea[data-codemirror]').each(function(element) {
    element.codemirror.save();
  });
});

$(document).on('ajax:complete', function() {
  Tabs.rescan();
  init_codemirrors();
});

"*[data-codemirror-button]".onClick(function(event) {
  if (event.which != 1) return;
  window['codemirror_' + this.data('codemirror-button')](this.parent('ul').next('textarea').codemirror);
});

".codemirror_buttons_fulscreen".onMouseenter('morph', {'top': '0px'});
".codemirror_buttons_fulscreen".onMouseleave('morph', {'top': '-20px'});

var codemirror_fullscreen = function(editor) {
  var scroll = $(editor.getWrapperElement()).children('.CodeMirror-scroll').first();
  var body = $$('body').first();

  if (scroll.hasClass('fullscreen')) {
    scroll.removeClass('fullscreen');
    editor.buttons.removeClass('codemirror_buttons_fulscreen');
    body.setStyle('overflow', 'auto');
  } else {
    scroll.addClass('fullscreen');
    editor.buttons.addClass('codemirror_buttons_fulscreen');
    body.setStyle('overflow', 'hidden');
  }

  editor.refresh();
  editor.focus();
}
