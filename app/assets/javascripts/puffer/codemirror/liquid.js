(function(CodeMirror) {
  inString = function(stream, state) {
    var matched = stream.next();

    while (stream.peek()) {
      if (stream.match('}}') || stream.match('%}')) {
        stream.backUp(2);
        break;
      } else if (stream.next() == matched) {
        break;
      }
    }

    return 'string';
  }

  CodeMirror.defineMode("liquid", function(config, parserConfig) {
    var tagMode = CodeMirror.getMode(config, "liquid-tag");
    var tagState = null;
    var variableMode = CodeMirror.getMode(config, "liquid-variable");
    var variableState = null;


    var tokenize = function(stream, state) {
      var token = null;

      if (stream.match(/^\{\%\s*comment\s*\%\}/)) {
        state.tokenizer = inComment;
        token = "comment";
      } else if (stream.match('{{')) {
        variableState = variableMode.startState();
        state.tokenizer = inVariable;
        token = 'tag';
      } else if (stream.match('{%')) {
        tagState = tagMode.startState();
        state.tokenizer = inTag;
        token = 'tag';
      } else {
        stream.next();
      }

      return token;
    }

    var inComment = function(stream, state) {
      if (stream.match(/^\{\%\s*endcomment\s*\%\}/)) {
        state.tokenizer = tokenize;
      } else {
        stream.next();
      }
      return 'comment';
    }

    var inVariable = function(stream, state) {
      var token = null;

      if (stream.match('}}')) {
        state.tokenizer = tokenize;
        token = 'tag';
      } else {
        token = variableMode.token(stream, variableState);
      }

      return token;
    }

    var inTag = function(stream, state) {
      var token = null;

      if (stream.match('%}')) {
        state.tokenizer = tokenize;
        token = 'tag';
      } else {
        token = tagMode.token(stream, tagState);
      }

      return token;
    }

    return {
      startState: function() {
        return {tokenizer: tokenize, mode: null};
      },
      token: function(stream, state) {
        return state.tokenizer(stream, state);
      },
      electricChars: ""
    }
  });

  CodeMirror.defineMode("liquid-variable", function(config, parserConfig) {
    var tokenize = function(stream, state) {
      var token = null;

      if (stream.peek() == '\'' || stream.peek() == '"') {
        token = inString(stream, state);
        state.filterParsing = false;
      } else if (stream.match(/^-?\d+(:?\.(\d+))?/)) {
        token = 'number';
        state.filterParsing = false;
      } else if (stream.peek() == '|') {
        stream.next();
        state.filterParsing = true;
      } else if (stream.match(/^\w+/)) {
        if (state.filterParsing) {
          token = 'attribute';
          state.filterParsing = false;
        } else {
          token = 'variable';
        }
      } else {
        stream.next();
      }

      return token;
    }

    return {
      startState: function() {
        return {tokenizer: tokenize, filterParsing: false};
      },
      token: function(stream, state) {
        return state.tokenizer(stream, state);
      },
      electricChars: ""
    }
  });

  CodeMirror.defineMode("liquid-tag", function(config, parserConfig) {
    var tokenize = function(stream, state) {
      var token = null;

      if (stream.peek() == '\'' || stream.peek() == '"') {
        token = inString(stream, state);
        if (state.translationTagParsed && !state.translationStringParsed) {
          token = 'translation';
        }
        state.translationStringParsed = true;
      } else if (stream.match(/^-?\d+(:?\.(\d+))?/)) {
        token = 'number';
        state.translationStringParsed = true;
      } else if (stream.match(/^(nil|null|true|false|empty|blank)\s/)) {
        token = 'builtin';
        stream.backUp(1);
        state.translationStringParsed = true;
      } else if (stream.match(/^(==|!=|<>|>|<|>=|<=)/)) {
        token = 'operator';
        state.translationStringParsed = true;
      } else if (stream.match(/^(in|contains)\s/)) {
        token = 'operator';
        stream.backUp(1);
        state.translationStringParsed = true;
      } else if (tag = stream.match(/^\w+/)) {
        if (state.tagParsed) {
          token = 'variable';
          state.translationStringParsed = true;
        } else {
          token = 'keyword';
          state.tagParsed = true;
          if (tag == 't' || tag == 'translate') {
            state.translationTagParsed = true;
          }
        }
      } else {
        stream.next();
      }

      return token;
    }

    return {
      startState: function() {
        return {tokenizer: tokenize, tagParsed: false, translationTagParsed: false, translationStringParsed: false};
      },
      token: function(stream, state) {
        return state.tokenizer(stream, state);
      },
      electricChars: ""
    }
  });
})(CodeMirror)

CodeMirror.defineMIME("text/x-liquid", "liquid");
CodeMirror.defineMIME("text/x-liquid-tag", "liquid-tag");
CodeMirror.defineMIME("text/x-liquid-variable", "liquid-variable");
