# N-Badge Authority with Badger Credentials

This repository contains the source code for the N-Badge Authority building on top of [Badger](https://trybadger.com). The N-Badge Authority system is an authority mechanism that powers complex function gating and access control using on-chain badges.

## Types of Authority Checks

* `NBMultiBalance`: Given a user and a set of access permissions with `mandatory` and `optional` badges from different SFT collections, check if the user has aggregate permission to access an on-chain resource. 
* `NBIDPacked`: Given a loop-index of bitpacked ids, check if the user has permission to access an on-chain resource using only `mandatory` badges that all belong to the same SFT collection.