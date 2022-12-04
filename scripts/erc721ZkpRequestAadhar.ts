import { ethers } from 'hardhat';

const main = async () => {
    const circuitId = "credentialAtomicQuerySig";
    const validatorAddress = "0xb1e86C4c687B85520eF4fd2a0d14e81970a15aFB";

    const verifierContract = "ERC721Verifier";
    
    const schemaHash = "f6a258b6d2783163a0be9d7c6d96f8f7";
    const ERC721VerifierAddress = "0x38ee862d0da4cc92c37f096511b232a7A428c237";
    const schemaEnd = fromLittleEndian(hexToBytes(schemaHash));
    const query = {
        schema: ethers.BigNumber.from(schemaEnd),
        slotIndex: 2, 
        operator: 2,
        value: [20010101, ...new Array(63).fill(0).map(i => 0)],
        circuitId,
    };

    // Retrieve contract to interact with it
    const erc721Verifier = await ethers.getContractAt(verifierContract, ERC721VerifierAddress);

    // Set zkpRequest for contract
    try {
        // Use as a means to keep track in the contract for number of mints a person can perform from a specific wallet address
        const requestId = Number(await erc721Verifier.TRANSFER_REQUEST_ID());
        const tx = await erc721Verifier.setZKPRequest(
            requestId, // 1
            validatorAddress,
            query
        );

        tx.wait();
        console.log(`Request set at:\nNOTE: May take a little bit to show up\nhttps://mumbai.polygonscan.com/tx/${tx.hash}`);
    } catch (e) {
        console.error("Error: ", e);
    }
};

// Helper Functions
// ========================================================
/**
 * 
 * @param hex 
 * @returns array of bytes
 */
const hexToBytes = (hex: string) => {
    for (var bytes = [], c = 0; c < hex.length; c += 2) {
        /**
         * @dev parseInt 16 = parsed as a hexadecimal number
         */
        bytes.push(parseInt(hex.substr(c, 2), 16));
    }
    return bytes;
};

/**
 * @dev Little-Endian: https://learnmeabitcoin.com/technical/little-endian
 * "Little-endian" refers to the order in which bytes of information can be processed by a computer.
 * @param bytes array of numbers for bytes 
 * @returns number
 */
const fromLittleEndian = (bytes: number[]) => {
    const n256 = BigInt(256);
    let result = BigInt(0);
    let base = BigInt(1);
    bytes.forEach((byte) => {
        result += base * BigInt(byte);
        base = base * n256;
    });
    return result;
};

// Init
// ========================================================
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
