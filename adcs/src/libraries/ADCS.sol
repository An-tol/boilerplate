// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Buffer} from "./Buffer.sol";
import {CBOR} from "./CBOR.sol";

library ADCS {
    uint256 internal constant DEFAULT_BUFFER_SIZE = 256; // Fixed constant naming

    using CBOR for Buffer.buffer;

    // Structure for storing off-chain requests
    struct Request {
        bytes32 id;
        address callbackAddr;
        bytes4 callbackFunc;
        uint256 nonce;
        Buffer.buffer buf;
    }

    /**
     * @notice Initializes a request
     * @dev Sets the ID, callback address, and callback function
     * @param self The uninitialized request
     * @param jobId The Job Specification ID
     * @param callbackAddr The callback address
     * @param callbackFunc The callback function signature
     * @return The initialized request
     */
    function initialize(
        Request memory self,
        bytes32 jobId,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal pure returns (Request memory) {
        require(callbackAddr != address(0), "ADCS: zero address"); // Added zero address check
        Buffer.init(self.buf, DEFAULT_BUFFER_SIZE);
        self.id = jobId;
        self.callbackAddr = callbackAddr;
        self.callbackFunc = callbackFunc;
        return self;
    }

    /**
     * @notice Sets the data for the buffer
     * @param self The initialized request
     * @param data The CBOR data
     */
    function setBuffer(Request memory self, bytes memory data) internal pure {
        require(data.length > 0, "ADCS: empty data"); // Added empty data check
        Buffer.init(self.buf, data.length);
        Buffer.append(self.buf, data);
    }

    /**
     * @notice Adds a key-value pair (string) to the request
     * @param self The initialized request
     * @param key The key name
     * @param value The string value
     */
    function add(Request memory self, string memory key, string memory value) internal pure {
        _validateKeyAndValue(key, value); // Moved validation to a separate function
        self.buf.encodeString(key);
        self.buf.encodeString(value);
    }

    /**
     * @notice Adds a key-value pair (bytes) to the request
     * @param self The initialized request
     * @param key The key name
     * @param value The bytes value
     */
    function addBytes(Request memory self, string memory key, bytes memory value) internal pure {
        _validateKey(key); // Moved key validation
        require(value.length > 0, "ADCS: empty value"); // Empty value check
        self.buf.encodeString(key);
        self.buf.encodeBytes(value);
    }

    /**
     * @notice Adds a key-value pair (int256) to the request
     * @param self The initialized request
     * @param key The key name
     * @param value The int256 value
     */
    function addInt(Request memory self, string memory key, int256 value) internal pure {
        _validateKey(key); // Moved key validation
        self.buf.encodeString(key);
        self.buf.encodeInt(value);
    }

    /**
     * @notice Adds a key-value pair (uint256) to the request
     * @param self The initialized request
     * @param key The key name
     * @param value The uint256 value
     */
    function addUInt(Request memory self, string memory key, uint256 value) internal pure {
        _validateKey(key); // Moved key validation
        self.buf.encodeString(key);
        self.buf.encodeUInt(value);
    }

    /**
     * @notice Adds an array of strings to the request in a key-value format
     * @param self The initialized request
     * @param key The key name
     * @param values The array of string values
     */
    function addStringArray(Request memory self, string memory key, string[] memory values) internal pure {
        _validateKey(key); // Moved key validation
        require(values.length > 0, "ADCS: empty values"); // Empty array check
        self.buf.encodeString(key);
        self.buf.startArray();
        for (uint256 i = 0; i < values.length; i++) {
            require(bytes(values[i]).length > 0, "ADCS: empty value in array"); // Empty value in array check
            self.buf.encodeString(values[i]);
        }
        self.buf.endSequence();
    }

    /**
     * @dev Internal function to validate the key
     * @param key The key name
     */
    function _validateKey(string memory key) private pure {
        require(bytes(key).length > 0, "ADCS: empty key");
    }

    /**
     * @dev Internal function to validate the key and value
     * @param key The key name
     * @param value The value
     */
    function _validateKeyAndValue(string memory key, string memory value) private pure {
        _validateKey(key);
        require(bytes(value).length > 0, "ADCS: empty value");
    }
}
