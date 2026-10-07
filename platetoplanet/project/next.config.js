/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: { 
    unoptimized: true 
  },
  // PWA configuration would go here in a real implementation
  // For now, we're using a basic service worker approach
};

module.exports = nextConfig;