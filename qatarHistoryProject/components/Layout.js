/*
  Layout Component
  Wrapper component that includes Header and Footer for all pages
*/

import Header from './Header';
import Footer from './Footer';

export default function Layout({ children }) {
  return (
    <>
      <Header />
      <main className="page-container">
        {children}
      </main>
      <Footer />
    </>
  );
}
