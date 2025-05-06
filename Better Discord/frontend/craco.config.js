const path = require('path');
const webpack = require('webpack');

module.exports = {
  webpack: {
    configure: (webpackConfig, { env, paths }) => {
      // Define a single clear output path
      paths.appBuild = path.join(__dirname, 'frontend', 'dist');
      webpackConfig.output.path = paths.appBuild;
      
      // Important for Electron loading resources
      webpackConfig.output.publicPath = './';

      // 1. Add .ts and .tsx to resolve.extensions
      webpackConfig.resolve.extensions.push('.ts', '.tsx');

      // 2. Define __DEV__ for Expo modules
      webpackConfig.plugins.push(
        new webpack.DefinePlugin({
          __DEV__: process.env.NODE_ENV !== 'production',
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
    }
  },
  babel: {
    plugins: [
      // Only use react-refresh in development, with skipEnvCheck set to true
      process.env.NODE_ENV === 'development' && [
        require.resolve('react-refresh/babel'),
        { skipEnvCheck: true }
      ]
    ].filter(Boolean)
  }
};