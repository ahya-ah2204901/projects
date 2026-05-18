/*
  Footer Component
  Site footer with student information and project details
*/

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="footer-container">
        <div className="footer-content">
          <h3>Academic Project</h3>
          <p>
            This website was created as part of the <strong>History of Qatar</strong> course
            <br />
            under the supervision of <strong>Dr. Tarig Mohamed</strong>
          </p>
          <p>
            By:<strong> Ahya AlWattar & Ganna Soltan</strong>
          </p>
        </div>

        <div className="footer-divider"></div>

        <div className="footer-bottom">
          <p>
            Exploring Qatari History and Heritage © {currentYear}
            <br />
            An educational project celebrating Qatar's rich cultural heritage
          </p>
        </div>
      </div>
    </footer>
  );
}
