const path = require('path');

module.exports = {
  mode: 'production',
  entry: './Amby/Resources/js/highlight.js',
  output: {
    filename: 'bundle.js',
    path: path.join(__dirname, './Amby/Resources/js/dist')
  }
};
