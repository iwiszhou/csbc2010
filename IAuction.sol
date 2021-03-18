// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAuction{
    function placeBid() external payable returns(bool);
    function withdraw() external payable returns(bool);
    function cancelAuction() external returns(bool);
}
