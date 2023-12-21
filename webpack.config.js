const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
   entry: './main.js',
   output: {
      path: path.join(__dirname, '/bundle'),
      filename: 'bundle.js'
   },
   devServer: {
	  contentBase: path.join(__dirname, '/bundle'),
      inline: true,
      port: 8001
   },
   module: {
      rules: [
         {
            test: /\.jsx?$/,
            exclude: /node_modules/,
            loader: 'babel-loader',
            query: {
               presets: ['es2015', 'react']
            }
         },
		 {
			test: /\.css$/,
			exclude: /node_modules/,
			use: [
			    'style-loader',
					{
						loader: 'css-loader',
						options: {
						importLoaders: 1,
						modules: true
					}
				}
			]
		 }
      ]
   },
   plugins:[
      new HtmlWebpackPlugin({
         template: './index.html'
      })
   ]
}