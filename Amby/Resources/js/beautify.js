var beautify = require('js-beautify').html;
var $ = require('jquery');

function beautify(html) {
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
//   console.log(beautify("<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><script src='./bundle.js'></script></head><body><h1 id='msg'>Hello JavaScript</h1></body></html>", beautifyOptions));
}