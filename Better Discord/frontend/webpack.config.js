const path = require('path');
const webpack = require('webpack');

module.exports = {
  webpack: {
    configure: (webpackConfig, { env, paths }) => {
      // 1. Add .ts and .tsx to resolve.extensions
      webpackConfig.resolve.extensions.push('.ts', '.tsx');

      // 2. Define __DEV__ for Expo modules
      webpackConfig.plugins.push(
        new webpack.DefinePlugin({
          __DEV__: process.env.NODE_ENV !== 'production',
          // You might also need these for other React Native / Expo variables
          'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
          __REACT_NATIVE__: false
        })
      );

      // 3. Find the babel-loader rule and modify it
      const babelLoaderRule = webpackConfig.module.rules.find(rule => 
        rule.oneOf?.some(oneOfRule => 
          oneOfRule.loader?.includes('babel-loader')
        )
      );

      if (babelLoaderRule) {
        babelLoaderRule.oneOf.forEach(rule => {
          if (rule.loader?.includes('babel-loader')) {
            // Include Expo and React Native modules for transpilation
            rule.include = [
              path.resolve(__dirname, 'src'),
              /node_modules[\\/]expo/,
              /node_modules[\\/]react-native/,
              /node_modules[\\/]react-native-web/
            ];
            // Ensure it handles both .js and .ts files
            rule.test = /\.(js|jsx|ts|tsx)$/;
          }
        });
      }

      // 4. Add specific rule for .ts files in node_modules
      webpackConfig.module.rules.push({
        test: /\.(ts|tsx)$/,
        include: [
          path.resolve(__dirname, 'node_modules/expo'),
          path.resolve(__dirname, 'node_modules/react-native'),
          path.resolve(__dirname, 'node_modules/react-native-web'),
        ],
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
              '@babel/preset-react',
              '@babel/preset-typescript'
            ],
            plugins: [
              'react-native-web'
            ]
          }
        }
      });

      return webpackConfig;
    },
    plugins: [
      // Additional webpack plugin to define __DEV__ globally
      new webpack.DefinePlugin({
        __DEV__: process.env.NODE_ENV !== 'production'
      })
    ]
  }
};