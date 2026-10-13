// Flattens CSS <style> blocks into plain attributes so flutter_svg can read
// them, while KEEPING the viewBox.
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
