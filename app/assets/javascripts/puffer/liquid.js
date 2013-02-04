CodeMirror.defineMode("text/x-liquid-html", function(config) {
  return CodeMirror.multiplexingMode(
    CodeMirror.getMode(config, "text/html"),
    {
      open: "{{", close: "}}",
      mode: CodeMirror.getMode(config, "text/x-liquid-variable"),
      delimStyle: "tag"
    },
    {
      open: "{%", close: "%}",
      mode: CodeMirror.getMode(config, "text/x-liquid-tag"),
      delimStyle: "tag"
    }
  );
});

CodeMirror.defineMode("text/x-liquid-yaml", function(config) {
  return CodeMirror.multiplexingMode(
    CodeMirror.getMode(config, "text/x-yaml"),
    {
      open: "{{", close: "}}",
      mode: CodeMirror.getMode(config, "text/x-liquid-variable"),
      delimStyle: "tag"
    },
    {
      open: "{%", close: "%}",
      mode: CodeMirror.getMode(config, "text/x-liquid-tag"),
      delimStyle: "tag"
    }
  );
});
