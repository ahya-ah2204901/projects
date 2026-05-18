# Exploring Qatari History and Heritage

An educational website showcasing Qatar's rich historical and cultural heritage, created as an academic project for the "History of Qatar" course.

## Project Overview

This Next.js-based website explores Qatar's most significant historical sites, from UNESCO World Heritage locations to modern cultural institutions. The project includes:

- **10 Historical Sites** - Detailed information about Qatar's most important landmarks
- **Interactive Quiz** - Test your knowledge about Qatari heritage
- **Educational Content** - Sourced from academic research and cultural institutions
- **Responsive Design** - Works perfectly on desktop, tablet, and mobile devices

## Technology Stack

- **Framework:** Next.js 14 (JavaScript)
- **Styling:** CSS Modules with global theme system
- **Deployment:** Optimized for Cloudflare Pages
- **No TypeScript, No Tailwind** - Pure JavaScript and CSS for simplicity

## Getting Started

### Prerequisites

- Node.js 18.17.0 or higher
- npm or yarn package manager

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repository-url>
   cd qatarHistoryProject
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Run the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure

```
qatarHistoryProject/
├── pages/                      # Next.js pages
│   ├── _app.js                # Custom App component
│   ├── _document.js           # Custom Document component
│   ├── index.js               # Home page
│   ├── 404.js                 # Custom 404 page
│   ├── about/
│   │   └── index.js           # About page
│   ├── historical-sites/
│   │   ├── index.js           # Sites listing page
│   │   └── [id].js            # Individual site detail page
│   ├── quiz/
│   │   └── index.js           # Interactive quiz page
│   └── references/
│       └── index.js           # References page
│
├── components/                 # React components
│   ├── Header.js              # Navigation header
│   ├── Footer.js              # Site footer
│   ├── Layout.js              # Layout wrapper
│   ├── SiteCard.js            # Historical site card
│   └── SiteCard.module.css    # Card styles
│
├── data/                       # Editable data files
│   ├── historicalSites.js     # Sites information
│   ├── quizQuestions.js       # Quiz questions
│   └── references.js          # APA references
│
├── styles/                     # CSS files
│   ├── theme.css              # Global theme (colors, fonts)
│   ├── globals.css            # Global styles
│   ├── layout.css             # Layout styles
│   └── *.module.css           # Page-specific styles
│
├── public/                     # Static assets
│   └── images/                # Historical site images
│
├── next.config.js             # Next.js configuration
├── package.json               # Dependencies
└── README.md                  # This file
```

## Editing Content

### Modifying Student Names and Information

1. **Footer Component** (`components/Footer.js`):
   - Replace `[Student Name 1]` and `[Student Name 2]` with actual names

2. **About Page** (`pages/about/index.js`):
   - Update student names and IDs in the Student Information section

3. **Document Head** (`pages/_document.js`):
   - Update the author meta tag

### Editing Historical Sites

Edit `/data/historicalSites.js`:

```javascript
{
  id: 'site-slug',
  title: 'Site Name',
  shortDescription: 'Brief description (2-3 lines)',
  fullDescription: 'Detailed description with paragraphs separated by \\n\\n',
  image: '/images/site-image.jpg',
  sources: ['APA citation 1', 'APA citation 2']
}
```

### Editing Quiz Questions

Edit `/data/quizQuestions.js`:

```javascript
{
  id: 1,
  question: 'Your question here?',
  options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
  correctAnswer: 0, // Index of correct option (0-3)
  explanation: 'Explanation shown after answering'
}
```

### Editing References

Edit `/data/references.js`:

```javascript
{
  id: 1,
  citation: 'Full APA-style citation here'
}
```

### Customizing Theme Colors

Edit `/styles/theme.css` to change the color scheme:

```css
:root {
  --color-sand: #E8D5C4;          /* Main sand color */
  --color-maroon: #6B2737;        /* Main maroon color */
  --color-gold: #B8860B;          /* Accent gold color */
  /* ... modify other colors as needed */
}
```

## Adding Images

1. Place your images in the `public/images/` directory
2. Name them according to the site IDs:
   - `al-zubarah-fort.jpg`
   - `souq-waqif.jpg`
   - `katara-cultural-village.jpg`
   - etc.

3. Images will automatically load. If an image is missing, a placeholder will be shown.

## Building for Production

### Local Build

```bash
npm run build
npm run start
```

This creates an optimized static export in the `out/` directory.

## Deploying to Cloudflare Pages

### Option 1: Using Cloudflare Dashboard (Recommended)

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages:**
   - Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Go to **Workers & Pages** → **Create Application** → **Pages**
   - Connect your GitHub repository

3. **Configure build settings:**
   - **Framework preset:** Next.js (Static HTML Export)
   - **Build command:** `npm run build`
   - **Build output directory:** `out`
   - **Environment variables:** None needed

4. **Deploy:**
   - Click "Save and Deploy"
   - Your site will be live at `https://your-project.pages.dev`

### Option 2: Using Wrangler CLI

1. **Install Wrangler:**
   ```bash
   npm install -g wrangler
   ```

2. **Login to Cloudflare:**
   ```bash
   wrangler login
   ```

3. **Build and deploy:**
   ```bash
   npm run build
   wrangler pages deploy out
   ```

### Custom Domain (Optional)

1. In Cloudflare Pages, go to your project
2. Click **Custom Domains**
3. Add your domain
4. Update DNS settings as instructed

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server locally
- `npm run lint` - Run ESLint

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## Features

### Responsive Design
- Mobile-first approach
- Adapts to all screen sizes
- Touch-friendly navigation

### Accessibility
- Semantic HTML
- ARIA labels where appropriate
- Keyboard navigation support
- Focus indicators

### Performance
- Static site generation
- Optimized images
- Minimal JavaScript
- Fast loading times

## Academic Information

**Course:** History of Qatar
**Instructor:** Dr. Tarig Ahmed Osman Mohamed
**Students:** [Student Name 1] & [Student Name 2]
**Year:** 2024

## References

All content is sourced from reliable academic and institutional sources including:
- Qatar Museums Authority
- UNESCO World Heritage Centre
- Peer-reviewed academic journals
- Official cultural institutions

See the References page on the website for complete citations.

## License

This is an academic project created for educational purposes.

## Support

For issues or questions about this project, please contact the students or course instructor.

## Acknowledgments

- Dr. Tarig Ahmed Osman Mohamed - Course instruction and guidance
- Qatar Museums - Historical information and resources
- UNESCO - Heritage site information
- Academic researchers whose work informed this project

---

**Built with ❤️ for Qatar's Heritage**
