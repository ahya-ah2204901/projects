/*
  Custom Document Component
  Customizes the HTML document structure
*/

import { Html, Head, Main, NextScript } from 'next/document';

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        <meta charSet="utf-8" />
        <meta name="description" content="Explore Qatar's rich history and heritage through historical sites, cultural landmarks, and educational content." />
        <meta name="keywords" content="Qatar, History, Heritage, Culture, Historical Sites, Museums, Architecture" />
        <meta name="author" content="[Student Name 1] & [Student Name 2]" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  );
}
