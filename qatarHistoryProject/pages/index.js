/*
  Home Page
  Landing page with hero section and introduction to Qatari heritage
*/

import Head from 'next/head';
import Link from 'next/link';
import styles from '@/styles/Home.module.css';

export default function Home() {
  return (
    <>
      <Head>
        <title>Exploring Qatari History and Heritage</title>
      </Head>

      {/* Hero Section */}
      <section className="hero">
        <div className="hero-content">
          <h1>Exploring Qatari History and Heritage</h1>
          <p>
            Explore Qatar’s heritage through historic sites, traditional architecture, 
            and cultural landmarks that tell the story of its past and present.
          </p>
          <div className={styles.heroButtons}>
            <Link href="/historical-sites/" className="btn btn-primary">
              Explore Historical Sites
            </Link>
            <Link href="/quiz/" className="btn btn-secondary">
              Test Your Knowledge
            </Link>
          </div>
        </div>
      </section>

      {/* Introduction Section */}
      <section className="section">
        <div className="container">
          <h2 className="section-title">Welcome to Qatar's Heritage Journey</h2>
          <div className={styles.introContent}>
            <p>
              Qatar's history is a fascinating blend of ancient traditions and modern achievements.
              For centuries, the Arabian Peninsula was home to Bedouin tribes and coastal communities
              whose livelihoods depended on pearling, fishing, and trade across the Gulf waters.
            </p>
            <p>
              Before the discovery of oil in the 1940s, Qatar was renowned as one of the finest
              sources of natural pearls in the world. The pearling industry shaped Qatari society,
              architecture, and culture, creating a unique maritime heritage that is preserved in
              museums, restored forts, and traditional souqs throughout the country.
            </p>
            <p>
              Today, Qatar balances its respect for tradition with ambitious modernization.
              Historical sites like Al Zubarah Fort, Souq Waqif, and the Museum of Islamic Art
              stand as testaments to the nation's commitment to preserving its cultural identity
              while embracing the future.
            </p>
          </div>

          {/* Feature Cards */}
          <div className={styles.features}>
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🏛️</div>
              <h3>9 Historical Sites</h3>
              <p>Explore UNESCO World Heritage Sites, museums, and cultural landmarks</p>
            </div>
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>📚</div>
              <h3>Rich Cultural History</h3>
              <p>Learn about Qatar's pearling heritage, traditional architecture, and ancient traditions</p>
            </div>
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🎓</div>
              <h3>Educational Content</h3>
              <p>Sourced from academic research and authoritative cultural institutions</p>
            </div>
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section className={styles.ctaSection}>
        <div className="container">
          <h2>Ready to Begin Your Journey?</h2>
          <p>Discover the stories, sites, and traditions that make Qatar unique</p>
          <Link href="/historical-sites/" className="btn btn-primary">
            Start Exploring
          </Link>
        </div>
      </section>
    </>
  );
}
