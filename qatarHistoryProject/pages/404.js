/*
  Custom 404 Error Page
  Displayed when a page is not found
*/

import Head from 'next/head';
import Link from 'next/link';
import styles from '@/styles/404.module.css';

export default function Custom404() {
  return (
    <>
      <Head>
        <title>Page Not Found - Exploring Qatari Heritage</title>
      </Head>

      <section className="section">
        <div className="container">
          <div className={styles.errorContainer}>
            <div className={styles.errorIcon}>🏛️</div>
            <h1 className={styles.errorCode}>404</h1>
            <h2 className={styles.errorTitle}>Page Not Found</h2>
            <p className={styles.errorMessage}>
              The page you're looking for seems to have wandered off into the desert sands.
              <br />
              Let's help you find your way back to exploring Qatar's heritage.
            </p>
            <div className={styles.errorActions}>
              <Link href="/" className="btn btn-primary">
                Return Home
              </Link>
              <Link href="/historical-sites/" className="btn btn-secondary">
                Explore Historical Sites
              </Link>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
