/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        pitch: {
          50: "#e8fff2",
          100: "#bff7d6",
          700: "#18a558",
          800: "#08773d",
          900: "#074427"
        },
        board: {
          50: "#f5f7fb",
          100: "#e6ebf3",
          200: "#b9c4d1",
          700: "#39424f",
          900: "#10151c"
        },
        result: {
          100: "#fff4bf",
          300: "#ffd84a",
          700: "#9b6100"
        },
        console: {
          100: "#dcecff",
          300: "#65a8ff",
          700: "#145cba",
          900: "#082144"
        }
      },
      fontFamily: {
        sans: [ "Rajdhani", "Arial Narrow", "Bahnschrift", "ui-sans-serif", "system-ui", "sans-serif" ]
      },
      boxShadow: {
        line: "inset 0 -1px 0 rgba(0, 0, 0, 0.08)"
      }
    }
  },
  plugins: []
};
