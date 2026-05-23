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
          50: "#eef8f0",
          100: "#d7f0dc",
          700: "#1f7a3f",
          800: "#165f33",
          900: "#104728"
        },
        board: {
          50: "#f7f7f2",
          100: "#eeeee4",
          200: "#d9d8c8",
          700: "#4b4a3f",
          900: "#24231d"
        },
        result: {
          100: "#fee8b5",
          300: "#f3b33f",
          700: "#8f4d08"
        }
      },
      fontFamily: {
        sans: [ "Inter", "ui-sans-serif", "system-ui", "sans-serif" ]
      },
      boxShadow: {
        line: "inset 0 -1px 0 rgba(0, 0, 0, 0.08)"
      }
    }
  },
  plugins: []
};
