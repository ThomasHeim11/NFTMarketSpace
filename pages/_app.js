//Installed modules
import { ThemeProvider } from 'next-themes';
import Script from 'next/script';
import Head from 'next/head';

//Ours
import { Navbar,Footer } from '../components';
import '../styles/globals.css';
import { NFTProvider } from '../context/NFTContext';

const MyApp = ({ Component, pageProps }) => (
  <NFTProvider>
    <ThemeProvider attribute='class'>
      <Head>
        <link rel="shortcut icon" href="/favicon.ico" />
        <title>NFTMarketSpace</title>
      </Head>
      <div className='dark:bg-nft-dark bg-white min-h-screen'>
        <Navbar></Navbar>
        <div className='pt-65'>
          <Component {...pageProps}/>
        </div>
        <Footer></Footer>
      </div>
      <Script src="https://kit.fontawesome.com/c1a1c44616.js" crossorigin="anonymous"></Script>
    </ThemeProvider>
  </NFTProvider>
)

export default MyApp
