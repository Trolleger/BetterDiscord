module.exports = {
    presets: ['babel-preset-react-app'],
    plugins: [
      process.env.NODE_ENV === 'development' && [
        require.resolve('react-refresh/babel'),
        { skipEnvCheck: true }
      ]
    ].filter(Boolean)
  };