//= require puffer/right-tabs-src
//= require puffer/codemirror
//= require puffer/multiplex
//= require puffer/matchbrackets
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


var fill_new_tab = function(tab) {
  var new_id = new Date().getTime();
  if (tab.main.data('new-panel'))
    tab.panel.update(tab.main.data('new-panel').replace(new RegExp(tab.main.data('new-panel-variable'), 'g'), new_id));

  var name_input = tab.panel.first('[data-acts="name"]');
  var name_panel = tab.panel.first().parent('[data-name]');
  if (name_input && name_panel) {
    name_input.value(name_panel.data('name'));
  }

  init_codemirrors();
}

var save_destroy_marks = function(scope) {
  var form = scope.tab.main.parent('form');
  scope.find('[data-acts="destroy"]').each(function(destroy_mark) {
    var page_part_param = destroy_mark.siblings('[data-acts="id"]').first();
    if (page_part_param) {
      form.insert(destroy_mark.value('true'), 'top');
      form.insert(page_part_param, 'top');
    }
  });
}

var init_codemirror = function(textarea) {
  if (!textarea.codemirror) {
    var codemirror = CodeMirror.fromTextArea(textarea._, {
      mode: textarea.data('codemirror').mode || 'text/html',
      lineNumbers: true,
      lineWrapping: true,
      tabSize: 2,
      extraKeys: {
        "Tab": "indentMore",
        "Shift-Tab": "indentLess",
        "Esc": codemirror_fullscreen,
        "Alt-Enter": codemirror_fullscreen
      }
    });

    textarea.codemirror = codemirror;
  }
}

var init_codemirrors = function() {
  $$('textarea[data-codemirror]').each(init_codemirror);
}

var set_codemirror_mode = function(select) {
  var editors = select.parent('.rui-tabs-panel').find('textarea[data-codemirror]');
  var selected = $(select._.selectedOptions[0]);
  var mode = selected.data('codemirror-mode');
  if (!mode.blank()) {
    editors.each(function(editor) {
      editor.codemirror.setOption("mode", mode);
    });
  }
}

var set_codemirrors_modes = function() {
  $$("select[data-codemirror-mode-select]").each(set_codemirror_mode);
}

"select[data-codemirror-mode-select]".on('change', function() { set_codemirror_mode(this) });

$(document).onReady(function() {
  init_codemirrors();
  set_codemirrors_modes();
});

$(document).on('data:sending', function() {
  $$('textarea[data-codemirror]').each(function(element) {
    element.codemirror.save();
  });
});

$(document).on('ajax:complete', function() {
  Tabs.rescan();
  init_codemirrors();
  set_codemirrors_modes();
});

var codemirror_fullscreen = function(editor) {
  var scroll = $(editor.getTextArea()).parents('*[data-fullscreen]').last();
  var body = $$('body').first();

  if (scroll.data('fullscreen')) {
    scroll.data('fullscreen', false)
    body.setStyle('overflow', 'auto');
  } else {
    scroll.data('fullscreen', true)
    body.setStyle('overflow', 'hidden');
  }

  editor.refresh();
  editor.focus();
}
