var beautify_js = require('js-beautify'); // also available under "js" export
var beautify_css = require('js-beautify').css;
var beautify_html = require('js-beautify').html;

export function printHtml() {
  var d = document;
  var c = d.charset || 0;
  var i = 0;
  var o = d.documentElement;
  d.write("<pre class=\"prettyprint\">" + (o.outerHTML || o.innerHTML).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") + "</pre>");
  d.body.style.fontSize = '110%';
  d.body.style.fontFamily = 'meiryo';

  var pre = document.querySelector("body > pre");
  var text = pre.textContent;
  var fmt = shapeHtml(text);
  pre.textContent = fmt;
}

function shapeHtml(html) {
  const beautifyOptions = {
    indent_size: 2,
    end_with_newline: true,
    preserve_newlines: false,
    max_preserve_newlines: 0,
    wrap_line_length: 0,
    wrap_attributes_indent_size: 0,
    unformatted: ['b', 'em']
  };

  return beautify_html(html, beautifyOptions);
}

