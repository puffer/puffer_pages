//= require puffer/right-tabs-src
//= require puffer/codemirror
//= require puffer/overlay
//= require puffer/codemirror/xml
//= require puffer/codemirror/javascript
//= require puffer/codemirror/css
//= require_tree ./codemirror
//= require puffer/liquid

Tabs.include({
  initialize: function(options) {
    this.$super(options);
    this.buildAddButton();
  },

  buildAddButton: function() {
    if (isFunction(this.options.addButton)) {
      this.addButton = $E('a', {'class': 'rui-tabs-tab rui-tabs-add', 'html': '<a href="#">+</a>'}).insertTo(this.tabsList);
      this.addButton.onClick(this.options.addButton.bind(this));
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

var page_part_tab_select = function(event) {
  var textarea = event.target.panel.first('textarea[data-codemirror]');
  if (textarea.codemirror) {
    textarea.codemirror.refresh();
  }
}

var page_part_tab_remove = function(event) {
  var destroy_mark = event.target.panel.first('.destroy_mark');
  var page_part_param = destroy_mark.next();
  $('page_parts_marked_for_destroy').append(destroy_mark.value('1'))
  if (page_part_param) {
    $('page_parts_marked_for_destroy').append(page_part_param);
  }
}

var page_part_tab_add = function(event) {
  event.stop();
  var new_id = new Date().getTime();
  var _this = this;
  new Dialog.Prompt({label: 'Enter new page part name'}).onOk(function() {
    var value = this.input.value();
    if (!value.blank()) {
      _this.add(value, new_page_part_tab_panel.replace(/new_page_part_tab_panel_index/g, new_id), {id: new_id});
      _this.tabs.last().panel.first('input[type=hidden]').value(value);
      _this.tabs.last().select();
      _this.addButton.insertTo(_this.tabsList);
      $$('textarea[data-codemirror]').each(init_codemirror);
      this.hide();
    }
  }).show();
}

var init_codemirror = function(textarea) {
  if (!textarea.codemirror) {
    var codemirror = CodeMirror.fromTextArea(textarea._, {
      mode: 'liquid',
      lineNumbers: true,
      lineWrapping: true,
      onCursorActivity: function(editor) {
        if (editor.last_active_line != undefined) {
          editor.setLineClass(editor.last_active_line, null);
        }
        editor.last_active_line = editor.getCursor().line;
        editor.setLineClass(editor.last_active_line, "active_line");
      },
      extraKeys: {
        "Esc": codemirror_fullscreen
      }
    });

    textarea.codemirror = codemirror;
    codemirror.buttons = textarea.prev('.codemirror_buttons');
  }
}

$(document).onReady(function() {
  $$('textarea[data-codemirror]').each(init_codemirror);
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
