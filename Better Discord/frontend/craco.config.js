const path = require('path');

module.exports = {
  webpack: {
    configure: (webpackConfig, { env, paths }) => {
      // 1. Add .ts and .tsx to resolve.extensions
      webpackConfig.resolve.extensions.push('.ts', '.tsx');

      // 2. Find the babel-loader rule and modify it
      const babelLoaderRule = webpackConfig.module.rules.find(rule => 
        rule.oneOf?.some(oneOfRule => 
          oneOfRule.loader?.includes('babel-loader')
        )
      );

      if (babelLoaderRule) {
        babelLoaderRule.oneOf.forEach(rule => {
          if (rule.loader?.includes('babel-loader')) {
            // 3. Include Expo and React Native modules for transpilation
            rule.include = [
              path.resolve(__dirname, 'src'),
              /node_modules[\\/]expo/,
              /node_modules[\\/]react-native/,
              /node_modules[\\/]react-native-web/
            ];
            // 4. Ensure it handles both .js and .ts files
            rule.test = /\.(js|jsx|ts|tsx)$/;
          }
        });
      }

      // 5. Add specific rule for .ts files in node_modules
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
              'react-native-web',
              // We're not adding react-refresh here at all
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