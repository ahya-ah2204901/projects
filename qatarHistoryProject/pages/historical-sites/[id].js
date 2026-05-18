/*
  Individual Site Detail Page
  Displays detailed information about a specific historical site
*/

import Head from 'next/head';
import Link from 'next/link';
import { getSiteById, getAllSiteIds } from '@/data/historicalSites';
import styles from '@/styles/SiteDetail.module.css';

export default function SiteDetail({ site }) {
  if (!site) {
    return (
      <div className="container section">
        <h1>Site not found</h1>
        <Link href="/historical-sites/" className="btn btn-primary">
          Back to Historical Sites
        </Link>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>{site.title} - Exploring Qatari Heritage</title>
        <meta name="description" content={site.shortDescription} />
      </Head>

      {/* Hero Image Section */}
      <div className={styles.heroImage}>
        <img
          src={site.image}
          alt={site.title}
          onError={(e) => {
            e.target.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1200" height="500"%3E%3Crect width="1200" height="500" fill="%23E8D5C4"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="32" fill="%236B2737"%3E' + site.title + '%3C/text%3E%3C/svg%3E';
          }}
        />
        <div className={styles.heroOverlay}>
          <div className="container">
            <h1>{site.title}</h1>
          </div>
        </div>
      </div>

      {/* Content Section */}
      <section className="section">
        <div className="container">
          {/* <div className={styles.backLink}>
            <Link href="/historical-sites/" className="btn btn-secondary">
              ← Back to All Sites
            </Link>
          </div> */}

          <div className={styles.content}>
            {/* Short Description */}
            <div className={styles.introduction}>
              <p className={styles.lead}>{site.shortDescription}</p>
            </div>

            {/* Full Description */}
            <div className={styles.fullDescription}>
              {site.fullDescription.split('\n\n').map((paragraph, index) => (
                <p key={index}>{paragraph}</p>
              ))}
            </div>

            {/* Sources Section */}
            {site.sources && site.sources.length > 0 && (
              <div className={styles.sources}>
                <h2>Sources</h2>
                <ul>
                  {site.sources.map((source, index) => (
                    <li key={index}>{source}</li>
                  ))}
                </ul>
              </div>
            )}

            {/* Navigation */}
            <div className={styles.navigation}>
              <Link href="/historical-sites/" className="btn btn-primary">
                View All Historical Sites
              </Link>
              <Link href="/quiz/" className="btn btn-secondary">
                Test Your Knowledge
              </Link>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}

// Generate static paths for all sites
export async function getStaticPaths() {
  const paths = getAllSiteIds();
  return {
    paths,
    fallback: false
  };
}

// Get site data for each path
export async function getStaticProps({ params }) {
  const site = getSiteById(params.id);
  return {
    props: {
      site
    }
  };
}
