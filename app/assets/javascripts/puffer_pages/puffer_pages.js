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
  }
});

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
    _this.add(this.input.value(), new_page_part_tab_panel.replace(/new_page_part_tab_panel_index/g, new_id), {id: new_id});
    _this.tabs.last().panel.first('input[type=hidden]').value(this.input.value());
    _this.tabs.last().select();
    _this.addButton.insertTo(_this.tabsList);
    this.hide();
  }).show();
}

var init_codemirror = function(textarea) {
  CodeMirror.fromTextArea(textarea._, {
    basefiles: "/assets/puffer_pages/codemirror-base.js",
    parserfile: "/assets/puffer_pages/codemirror-parser.js",
    stylesheet: "/assets/puffer_pages/codemirror.css",
    tabMode: 'shift'
  });
}

$(document).onReady(function() {
  $$('textarea[codemirror]').each(init_codemirror);
});
