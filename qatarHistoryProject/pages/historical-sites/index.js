/*
  Historical Sites Index Page
  Displays all historical sites in a grid layout
*/

import Head from 'next/head';
import SiteCard from '@/components/SiteCard';
import { historicalSites } from '@/data/historicalSites';
import styles from '@/styles/HistoricalSites.module.css';

export default function HistoricalSites() {
  return (
    <>
      <Head>
        <title>Historical Sites - Exploring Qatari Heritage</title>
        <meta name="description" content="Discover Qatar's most significant historical and cultural sites, from UNESCO World Heritage Sites to modern museums." />
      </Head>

      {/* Page Header */}
      <section className="hero">
        <div className="hero-content">
          <h1>Historical Sites of Qatar</h1>
          <p>
            Explore Qatar's most treasured historical and cultural landmarks,
            each telling a unique story of the nation's rich heritage
          </p>
        </div>
      </section>

      {/* Sites Grid */}
      <section className="section">
        <div className="container">
          <div className={styles.sitesGrid}>
            {historicalSites.map((site) => (
              <SiteCard key={site.id} site={site} />
            ))}
          </div>
        </div>
      </section>

      {/* Info Section */}
      <section className={styles.infoSection}>
        <div className="container">
          <h2>Preserving Heritage</h2>
          <p>
            These historical sites represent Qatar's commitment to preserving its cultural
            heritage while embracing modernity. Each location has been carefully maintained
            or restored to provide insight into Qatar's pearling past, traditional
            architecture, and Islamic cultural heritage.
          </p>
        </div>
      </section>
    </>
  );
}
