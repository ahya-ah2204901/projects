/*
  About Page
  Information about the project, course, and students
*/

import Head from 'next/head';
import styles from '@/styles/About.module.css';

export default function About() {
  return (
    <>
      <Head>
        <title>About This Project - Exploring Qatari Heritage</title>
        <meta name="description" content="Learn about this educational project exploring Qatar's rich history and cultural heritage." />
      </Head>

      {/* Page Header */}
      <section className="hero">
        <div className="hero-content">
          <h1>About This Project</h1>
          <p>An educational journey through Qatar's rich historical and cultural heritage</p>
        </div>
      </section>

      {/* Content Section */}
      <section className="section">
        <div className="container">
          <div className={styles.content}>
            {/* Project Overview */}
            <div className={styles.card}>
              <h2>Project Overview</h2>
              <p>
                This website was created as an academic project for the <strong>History of Qatar</strong> course
                under the supervision of <strong>Dr.Tarig Mohamed</strong>. The project aims to
                explore and present Qatar's rich historical and cultural heritage through an accessible,
                educational digital platform.
              </p>
              <p>
                Through this website, we seek to highlight the significance of Qatar's historical sites,
                from ancient archaeological treasures to modern cultural institutions. Each site tells a
                unique story about the nation's journey from a pearling economy to a modern state, while
                maintaining its cultural identity and traditions.
              </p>
            </div>

            {/* Student Information */}
            <div className={styles.card}>
              <h2>Student Information</h2>
              <div className={styles.students}>
                <div className={styles.student}>
                  <div className={styles.studentIcon}>👤</div>
                  <div className={styles.studentInfo}>
                    <h3>Ahya AlWattar</h3>
                    <p>Student at Qatar University College of Engineering</p>
                  </div>
                </div>
                <div className={styles.student}>
                  <div className={styles.studentIcon}>👤</div>
                  <div className={styles.studentInfo}>
                    <h3>Ganna Soltan</h3>
                    <p>Student at Qatar University College of Engineering</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Course Information */}
            <div className={styles.card}>
              <h2>Course Information</h2>
              <div className={styles.courseInfo}>
                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Course:</span>
                  <span className={styles.infoValue}>HIST 121 - History of Qatar</span>
                </div>
                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Instructor:</span>
                  <span className={styles.infoValue}>Dr. Tarig Ahmed Osman Mohamed</span>
                </div>
                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Semester: </span>
                  <span className={styles.infoValue}>Fall 2025</span>
                </div>
              </div>
            </div>

            {/* Instructor Information */}
            <div className={styles.insCard}>
              <h2>Instructor Information</h2>
              <div className={styles.courseInfo}>

                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Name:</span>
                  <span className={styles.infoValue}>Dr. Tarig Ahmed Osman Mohamed</span>
                </div>
                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Position:</span>
                  <span className={styles.infoValue}>Associate Professor, Humanities Department</span>
                </div>
                <div className={styles.infoRow}>
                  <span className={styles.infoLabel}>Institution:</span>
                  <span className={styles.infoValue}>College of Arts and Sciences, Qatar University</span>
                </div>

              </div>
              {/* Instructor Image (outside the colored box) */}
              <div className={styles.instructorImage}>
                <img
                  src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfiH7fCHxzqB1MbRn6EDg7e9cqoQt6ZQ_yNQ&s" // Replace with your actual image path or URL
                  alt="Dr. Tarig Ahmed Osman Mohamed"
                />
              </div>
            </div>

            {/* Project Reflection */}
            <div className={styles.card}>
              <h2>Reflection</h2>
              <p>
                Creating this website has been an enriching experience that deepened our understanding
                of Qatar's cultural heritage. Through extensive research and exploration of academic
                sources, we gained valuable insights into the historical significance of Qatar's landmarks
                and the importance of preserving cultural identity in a rapidly modernizing world.
              </p>
              <p>
                We hope this website serves as a useful educational resource for anyone interested in
                learning about Qatar's fascinating history, from its ancient rock carvings to its
                world-class museums. The journey through these historical sites reveals not just
                architectural achievements, but the spirit and resilience of the Qatari people throughout
                the centuries.
              </p>
              <p>
                All content is sourced from reliable academic and institutional references, including
                publications from Qatar Museums, UNESCO, and scholarly journals. The website features
                interactive elements including a quiz to test knowledge about Qatari heritage, making
                learning engaging and memorable.
              </p>
            </div>

            {/* Acknowledgments */}
            <div className={styles.card}>
              <h2>Acknowledgments</h2>
              <p>
                We would like to express our gratitude to <strong>Dr.Tarig Mohamed</strong> for
                his guidance and instruction throughout this course. We also acknowledge the valuable resources
                provided by Qatar Museums, UNESCO World Heritage Centre, and the various scholars whose research
                has contributed to our understanding of Qatari history and culture.
              </p>
              <p>
              </p>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
