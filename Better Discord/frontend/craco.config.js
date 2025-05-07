const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  webpack: {
    configure: (webpackConfig, { env, paths }) => {
      // ===== 1. Output Configuration =====
      paths.appBuild = path.join(__dirname, 'frontend', 'dist');
      webpackConfig.output = {
        ...webpackConfig.output,
        path: paths.appBuild,
        publicPath: 'auto', // Fixes injection issues for both Electron and Web
        filename: env === 'production' ? 'static/js/[name].[contenthash:8].js' : 'static/js/bundle.js',
      };

      // ===== 2. Fix HTML Injection =====
      // Remove existing HtmlWebpackPlugin (if any)
      const htmlPluginIndex = webpackConfig.plugins.findIndex(
        plugin => plugin instanceof HtmlWebpackPlugin
      );
      if (htmlPluginIndex !== -1) {
        webpackConfig.plugins.splice(htmlPluginIndex, 1);
      }

      // Add new HtmlWebpackPlugin with correct settings
      webpackConfig.plugins.push(
        new HtmlWebpackPlugin({
          template: path.resolve(__dirname, 'public/index.html'),
          filename: 'index.html',
          inject: 'body', // Ensures JS is injected at the end of <body>
          minify: env === 'production' ? {
            collapseWhitespace: true,
            removeComments: true,
          } : false,
        })
      );

      // ===== 3. React Native Web Compatibility =====
      webpackConfig.resolve.alias = {
        ...webpackConfig.resolve.alias,
        'react-native$': 'react-native-web',
      };

      // ===== 4. Environment Variables =====
      webpackConfig.plugins.push(
        new webpack.DefinePlugin({
          __DEV__: env === 'development',
          'process.env.NODE_ENV': JSON.stringify(env),
          __REACT_NATIVE__: JSON.stringify(false), // Force React Native Web mode
        })
      );

      // ===== 5. Babel Loader Fix =====
      const babelLoaderRule = webpackConfig.module.rules.find(rule =>
        rule.oneOf?.some(oneOfRule => oneOfRule.loader?.includes('babel-loader'))
      );

      if (babelLoaderRule) {
        babelLoaderRule.oneOf.forEach(rule => {
          if (rule.loader?.includes('babel-loader')) {
            rule.include = [
              path.resolve(__dirname, 'src'),
              /node_modules[\\/]expo/,
              /node_modules[\\/]react-native/,
              /node_modules[\\/]react-native-web/,
            ];
            rule.test = /\.(js|jsx|ts|tsx)$/;
          }
        });
      }

      return webpackConfig;
    },
  },
  babel: {
    plugins: [
      process.env.NODE_ENV === 'development' && [
        'react-refresh/babel',
        { skipEnvCheck: true }
      ],
    ].filter(Boolean),
  },
};