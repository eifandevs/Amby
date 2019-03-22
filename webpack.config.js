var webpack = require("webpack");
const path = require('path');

module.exports = {
  mode: 'production',
  entry: './Amby/Resources/client/js/shaper.js',
  output: {
    filename: 'bundle.js',
    path: path.join(__dirname, './Amby/Resources/client/js/dist')
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      utils: path.join(__dirname, './Amby/Resources/client/js/shaper.js')
    })
  ]
};
