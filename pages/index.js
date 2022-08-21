import { Banner, CreatorCard, NFTCard } from "../components";
import { useState, useEffect, useRef} from "react";
import images from "../assets";
import { makeId } from '../utils/makeId';
import Image from "next/image";
import { useTheme } from "next-themes";


const Home = () => { 
  const [hideButtons, setHideButtons] = useState(false);
  const { theme } = useTheme();
  const parentRef = useRef(null);
  const [hideButton, setHideButton] = useState(false);
  const parrentRef = useRef(null);
  const scrollRef = useRef(null);

  const handleScroll = (direction) => { 
    const {current } = scrollRef;

    const scrollAmount = window.innerWidth > 1800 ? 270 :210;

    if(direction === "left") {
      current.scrollLeft -= scrollAmount;
    } else { 
      current.scrollLeft += scrollAmount;
    }
  };

  const isScrollable = () => {
    const { current } = scrollRef;
    const { current: parent } = parentRef;

    if (current?.scrollWidth >= parent?.offsetWidth) {
      setHideButton(false);
    } else {
      setHideButton(true);
    }
  };

  useEffect(() => {
    isScrollable();
    window.addEventListener("resize", isScrollable);

    return () => {
      isScrollable();
      window.removeEventListener("resize", isScrollable);
    }
  });

  return (
    <div className='flex justify-center sm:px-4 p-12'>
      <div className='w-full minmd:w-4/5'>
        <Banner
          parentStyles='justify-start mb-6 h-72 sm:h-60 p-12 xs:p-4 xs:h-44 rounded-3xl'
          childStyles='md:text-4xl sm:text-2xl xs:text-xl text-left text-white'
          name={
            <>
              Discover, collect, and sell <br /> extraordinary NFTs
            </>
          }
        />
    <div>
      <hi className="font-poppins dark:text-white
      text-nft-black-1 text-2x1 minlg:text-4x1
      font-semibold ml-4 xs:ml-0">Best Creators</hi>

      <div className="relative flex-1 max-w-full flex mt-3"
      ref={parrentRef}>
      <div className="flex flex-row w-max
      owerflow-x-scroll no scrollbar select-none" ref=
      {scrollRef}>
     {[1, 2, 3, 4, 5, 6].map((i) => (
        <CreatorCard
          key={`creator-${i}`}
          rank={i}
          creatorImage={images[`creator${i}`]}
          creatorName={`0x${makeId(3)}...${makeId(4)}`}
          creatorEths={10 - i * 0.5}
          />
        ))}
        {!hideButtons && (
        <> 
         <div onClick={() => handleScroll("left")} 
         className="absolute w-8 h-8 minlg:w-12
          minlg:h-12 top-45 cursor-pointer left-0"> 
            <Image src={images.left} layout="fill"
            objectFit="contain" alt="left_arrow" 
            className={theme === "light" && "filter invert"}
            />
          </div>

          <div onClick={() => handleScroll("left")}
          className="absolute w-8 h-8 minlg:w-12
          minlg:h-12 top-45 cursor-pointer right-0"> 
            <Image src={images.right} layout="fill"
            objectFit="contain" alt="left_arrow" 
            className={theme === "light" && "filter invert"} />
          </div>
          </>
          )}
        </div>
      </div>
    </div>

    <div className="mt-10">
        <div className="flexBetwenn mx-4 xs:mx-0 
        minlg:mx-8 sm:felx.col sm:items-start">
          <hi className='font-poppins dark:text-white text-nft-black-1 text-2xl minlg:text-4xl font-semibold sm:mb-4 flex-1'> 
          Hot NFTs
          </hi>
            </div>
        <div className='mt-3 w-full flex flex-wrap justify-start
         md:justify-center'>
               {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((i) => (
              <NFTCard
                key={`nft-${i}`}
                nft={{
                  i: i,
                  name: `Nifty NFT ${i}`,
                  price: 10 - i * 0.5,  
                  seller: `0x${makeId(3)}...${makeId(4)}`,
                  owner: `0x${makeId(3)}...${makeId(4)}`,
                  description: "Cool NFT on Sale",
                }}
              />
            ))}

        </div>

    </div>
  </div>
  </div> 

     
        

);
}

export default Home;