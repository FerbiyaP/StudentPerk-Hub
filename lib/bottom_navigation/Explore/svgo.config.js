// Flattens CSS <style> blocks into plain attributes so flutter_svg can read
// them, while KEEPING the viewBox.
//   cp -r lib/assets/logos logos_backup
//   npx svgo -f lib/assets/logos --config svgo.config.js
module.exports = {
  plugins: [
    {
      name: 'preset-default',
      params: { overrides: { removeViewBox: false } },
    },
    'inlineStyles',
    'convertStyleToAttrs',
  ],
};