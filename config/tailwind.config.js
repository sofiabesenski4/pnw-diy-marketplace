module.exports = {
  darkMode: 'class',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*',
    './app/components/**/*'
  ],
  theme: {
    screens: {
      xs: '320px',
      sm: '576px',
      md: '768px',
      lg: '992px',
      xl: '1200px',
      '2xl': '1386px',
      '3xl': '1536px',
    },
    // Ballpoint Punk type: Courier Prime for body and UI, Rock Salt for
    // headings (the existing `serif` slots), Reenie Beanie for handwritten notes.
    fontFamily: {
      sans: ['"Courier Prime"', 'ui-monospace', 'monospace'],
      'sans-md': ['"Courier Prime"', 'ui-monospace', 'monospace'],
      serif: ['"Rock Salt"', 'cursive'],
      'serif-md': ['"Rock Salt"', 'cursive'],
      hand: ['"Reenie Beanie"', 'cursive'],
    },
    // Rock Salt runs large and tall, so headings are smaller with roomier leading.
    fontSize: {
      h1: ['2.75rem', '150%'],
      h2: ['2.5rem', '150%'],
      'h2.5': ['2.375rem', '150%'],
      h3: ['2.25rem', '150%'],
      h4: ['1.875rem', '150%'],
      h5: ['1.625rem', '150%'],
      h6: ['1.375rem', '150%'],
      'body-lg': ['1.5rem', '150%'],
      'body-22': ['1.375rem', '150%'],
      'body-20': ['1.25rem', '140%'],
      'body-md': ['1.125rem', '140%'],
      body: ['1rem', '120%'],
      'body-15.5': ['0.968rem', '120%'],
      'body-sm': ['0.875rem', '120%'],
      'body-xs': '0.75rem',
      'body-2xs': '0.625rem',
      eyebrow: [
        '0.875rem',
        {
          lineHeight: '1',
          letterSpacing: '0.07em',
        },
      ],
      caption: ['0.75rem', '150%'],
    },
    extend: {
      aspectRatio: {
        auto: "auto",
        square: "1 / 1",
        "4/5": "4 / 5",
        "4/5_3": "4 / 5.3",
      },
      backgroundSize: {
        '85': '85%',
      },
      boxShadow: {
        'ink': '4px 5px 0 #141414',
        'ink-lg': '6px 7px 0 #141414',
        'bic': '6px 6px 0 #1F3A93',
        'bic-lg': '9px 9px 0 #1F3A93',
        'note': '5px 6px 0 rgba(20, 20, 20, .2)',
      },
      borderRadius: {
        '2xl': '2rem',
        'wonky': '4px 14px 5px 12px',
        'wonky-sm': '3px 9px 4px 11px',
      },
      colors: {
        // Ballpoint Punk tokens. `black`, `sand`, `primary` and `gray-50` are
        // remapped so existing markup picks up ink, paper, bic blue and the photo well.
        paper: '#FBFAF3',
        ink: '#141414',
        bic: '#1F3A93',
        'red-pen': '#B42B25',
        rule: '#BFD3EC',
        margin: '#E58F8F',
        sticky: '#FFF3A8',
        highlighter: '#F5D76E',
        well: '#F3F1E7',
        tape: 'rgba(233, 220, 170, .85)',
        primary: '#1F3A93',
        black: '#141414',
        'light-black': '#333333',
        sand: '#FBFAF3',
        pink: '#F6D7E2',
        seafoam: '#C1E0DE',
        plum: '#3A0E31',
        sky: '#CBDFF1',
        moss: '#2D3925',
        blue: '#2554B1',
        midnight: '#163449',
        orange: '#F68050',
        yellow: '#FDC071',
        forrest: '#096756',
        dune: '#E6BF9B',
        'solidus-red': '#1F3A93',
        red: {
          100: '#F8D7D4',
          200: '#F1AFA9',
          300: '#EA877E',
          400: '#E35F53',
          500: '#DC3728',
          600: '#B02C20',
        },
        gray: {
          primary: '#C7CCC7',
          mid: '#D8DAD8',
          25: '#FAFAFA',
          50: '#F3F1E7',
          100: '#DDDDDD',
          200: '#CFCFCF',
          300: '#BBBBBB',
          400: '#A2A2A2',
          500: '#828282',
          600: '#616161',
          700: '#4B4B4B',
          800: '#333333',
        },
      },
      width: {
        '1_col-3': '32%',
        'collection-card': 'calc(33%-12px)' // assumes 3 cards shown with space-x-6 (24px) in between.
      },
      height: {
        '1_col-3': '32%',
      },
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography')
  ]
}
