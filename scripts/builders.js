const {Wallet, JsonRpcProvider, Contract, parseEther} = require("ethers");


const walletBuilder = (privateKey) => {
    return new Wallet(privateKey)
}

const providerBuilder = (url) => {
    return new JsonRpcProvider(url)
}

const signerBuilder = (privateKey, url) => {
    //TO DO: allow handling for encrypted private keys
    const currentProvider = providerBuilder(url);
    // const signer = new Wallet("12345"+"salt", new JsonRpcProvider(url));
    // signer.address

    return new Wallet(privateKey, currentProvider);
}


const eventBuilder = async(contractABI, contractAddress, providerUrl) => {
    const provider = providerBuilder(providerUrl);
    const contractObject = Contract(contractAddress, contractABI, provider);

    console.log(`Listening for any event emitted by the contract at ${contractAddress}...`);

    contractObject.on("*", (...args) => {
        const eventParams = args.slice(0, -1);
        const event = args[args.length - 1];

        console.log(`Event emitted:`);
        console.log('Event parameters:', eventParameters);
        console.log('Event details:', event);

        return event;
    })
}   


const contractBuilder = (contractABI, contractAddress, signer) => {
    return new Contract(contractAddress, contractABI, signer);
}

const unitsBuilder = (units) => {
    if( typeof units !== "number" ) {
        throw new Error("Units must be a number")
    }
    return parseEther(units.toString())
}






module.exports = { walletBuilder, providerBuilder, eventBuilder, signerBuilder, contractBuilder, unitsBuilder }