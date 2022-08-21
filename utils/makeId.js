export const makeId = (length) => {
    let result = '';
    const characters = '0x02e4Fd31CB6f4f4be46cC23765Ce61a0f77D9082';
    const charactersLength = characters.length;
  
    for (let i=0; i< length; i+=1){
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
  
    return result;
  }