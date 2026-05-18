/*
  Site Card Component
  Displays a historical site as a card with image, title, description, and link
*/

import Link from 'next/link';
import styles from './SiteCard.module.css';

export default function SiteCard({ site }) {
  return (
    <div className="card">
      <div className={styles.cardImage}>
        <img
          src={site.image}
          alt={site.title}
          className="responsive-img"
          onError={(e) => {
            // Fallback to placeholder if image fails to load
            e.target.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="400" height="300"%3E%3Crect width="400" height="300" fill="%23E8D5C4"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="20" fill="%236B2737"%3E' + site.title + '%3C/text%3E%3C/svg%3E';
          }}
        />
      </div>
      <div className={styles.cardContent}>
        <h3 className={styles.cardTitle}>{site.title}</h3>
        <p className={styles.cardDescription}>{site.shortDescription}</p>
        <Link href={`/historical-sites/${site.id}/`} className="btn btn-primary">
          Learn More
        </Link>
      </div>
    </div>
  );
}
