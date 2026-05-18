/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable static exports for Cloudflare Pages
  output: 'export',

  // Disable image optimization for static export
  images: {
    unoptimized: true,
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
    ],
  },
  experimental: {
    staticGenerationRetryCount: 2,
  },
  // Add trailing slash for better compatibility
  trailingSlash: false,
}

module.exports = nextConfig
