import React from 'react';
import Image from 'next/image';

import images from '../assets';

const Loader = () => {
  return (
    <div className='flexCenter w-full my-4'>
      <Image src={images.loaderNew} alt='loader' width={120} objectFit='contain' />
    </div>
  )
}

export default Loader