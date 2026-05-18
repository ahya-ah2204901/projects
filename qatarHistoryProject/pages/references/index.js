/*
  References Page
  APA-style references for all sources used in the project
*/

import Head from "next/head";
import { references } from "@/data/references";
import styles from "@/styles/References.module.css";

export default function References() {
  return (
    <>
      <Head>
        <title>References - Exploring Qatari Heritage</title>
        <meta
          name="description"
          content="Academic references and sources used in this project about Qatar's history and heritage."
        />
      </Head>

      {/* Page Header */}
      <section className="hero">
        <div className="hero-content">
          <h1>References</h1>
          <p>Academic sources and references used in this project</p>
        </div>
      </section>

      {/* References Content */}
      <section className="section">
        <div className="container">
          <div className={styles.content}>
            {/* References List */}
            <div className={styles.referencesContainer}>
              <h2>Bibliography</h2>
              <div className={styles.referencesList}>
                {references.map((reference) => (
                  <a
                    key={reference.id}
                    href={reference.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={styles.referenceLink}
                  >
                    <div className={styles.reference}>
                      <span className={styles.referenceNumber}>
                        {reference.id}
                      </span>
                      <p className={styles.referenceCitation}>
                        {reference.citation}
                      </p>
                    </div>
                  </a>
                ))}
              </div>
            </div>
            {/* Introduction */}
            <div className={styles.introduction}>
              <p>
                This project draws from authoritative academic sources,
                institutional publications, and cultural heritage organizations.
                All information presented on this website has been carefully
                researched and cited according to APA style guidelines.
                The references represent the scholarly foundation of our
                exploration of Qatari history and heritage.
              </p>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
