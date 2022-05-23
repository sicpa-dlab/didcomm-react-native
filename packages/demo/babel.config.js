const presets = ['module:metro-react-native-babel-preset']
const plugins = [
  [
    'module-resolver',
    {
      root: ['.'],
      extensions: ['.tsx', 'ts'],
    },
  ],
]

module.exports = {
  presets,
  plugins,
}
