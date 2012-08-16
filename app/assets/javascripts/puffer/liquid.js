CodeMirror.defineMode("liquid", function(config) {
  return CodeMirror.multiplexingMode(
    CodeMirror.getMode(config, "text/html"),
    {
      open: "{{", close: "}}",
      mode: CodeMirror.getMode(config, "text/plain"),
      delimStyle: "liquid-variable"
    },
    {
      open: "{%", close: "%}",
      mode: CodeMirror.getMode(config, "text/plain"),
      delimStyle: "liquid-tag"
    }
  );
});
