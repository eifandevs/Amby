var beautify = require('js-beautify').html;

export function printHtml() {
  var d=document;
  var c=d.charset||0;
  var i=0;
  var o=d.documentElement;
  d.write("<pre class=\"prettyprint\">"+(o.outerHTML||o.innerHTML).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")+"</pre>");
  d.body.style.fontSize = '120%';
  d.body.style.fontFamily = 'meiryo';
}

function unescapeHTML(str) {
  var div = document.createElement("div");
  div.innerHTML = str.replace(/</g,"&lt;")
                     .replace(/>/g,"&gt;")
                     .replace(/ /g, "&nbsp;")
                     .replace(/\r/g, "&#13;")
                     .replace(/\n/g, "&#10;");
  return div.textContent || div.innerText;
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

  return beautify(html, beautifyOptions);
}

