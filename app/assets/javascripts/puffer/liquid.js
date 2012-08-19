CodeMirror.defineMode("liquid-mixed", function(config) {
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
