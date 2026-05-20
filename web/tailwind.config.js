/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#008088',
        black: '#000000',
        white: '#ffffff',
        textgrey: '#6b7280',
        fildbg: '#f5f8fa',
        light: '#e6f7f7',
        dark: '#005555',
        teal700: '#0d9488',
        red: '#880808',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        soft: '0 4px 24px -4px rgba(0, 128, 136, 0.12)',
      },
    },
  },
  plugins: [],
};
