const defaultTheme = require('tailwindcss/defaultTheme')
const execSync = require('child_process').execSync;
const pagyPath = execSync('bundle show pagy').toString().trim();

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    pagyPath + '/**/*' // Permet à Tailwind de voir les classes CSS de Pagy
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}