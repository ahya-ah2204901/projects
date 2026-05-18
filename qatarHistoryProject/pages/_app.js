/*
  Custom App Component
  Wraps all pages with global styles and layout
*/

import Layout from '@/components/Layout';
import '@/styles/theme.css';
import '@/styles/globals.css';
import '@/styles/layout.css';

export default function App({ Component, pageProps }) {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  );
}
