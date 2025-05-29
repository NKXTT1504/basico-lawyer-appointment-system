/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f4f9',
          100: '#d9e2ec',
          200: '#bcceda',
          300: '#92adc1',
          400: '#6688a6',
          500: '#4a6a8a',
          600: '#345374',
          700: '#102C57', // Primary navy blue
          800: '#0f1e3a',
          900: '#0a1325',
        },
        accent: {
          50: '#fdf8ef',
          100: '#f9ecd6',
          200: '#f2d9ad',
          300: '#DDA94B', // Gold accent
          400: '#d59220',
          500: '#b87b18',
          600: '#9c6114',
          700: '#7a4a13',
          800: '#633b15',
          900: '#513214',
        },
        success: {
          50: '#ecfdf5',
          100: '#d1fae5',
          500: '#10b981',
          700: '#047857',
        },
        warning: {
          50: '#fffbeb',
          100: '#fef3c7',
          500: '#f59e0b',
          700: '#b45309',
        },
        error: {
          50: '#fef2f2',
          100: '#fee2e2',
          500: '#ef4444',
          700: '#b91c1c',
        }
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Arial', 'sans-serif'],
        serif: ['Merriweather', 'ui-serif', 'Georgia', 'Cambria', 'Times New Roman', 'serif'],
      },
      boxShadow: {
        'soft': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.5s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: 0 },
          '100%': { opacity: 1 },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: 0 },
          '100%': { transform: 'translateY(0)', opacity: 1 },
        },
      },
      backgroundImage: {
        'hero-pattern': "linear-gradient(to right, rgba(16, 44, 87, 0.8), rgba(16, 44, 87, 0.7)), url('https://images.pexels.com/photos/5668789/pexels-photo-5668789.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2')",
      },
    },
  },
  plugins: [],
};