# N-Badge Authority with Badger Credentials

This repository contains the source code for the N-Badge Authority building on top of [Badger](https://trybadger.com). The N-Badge Authority system is an authority mechanism that powers complex function gating and access control using on-chain badges.

## The Operational Options

When utilizing on-chain actions, it is often a desire to be able to gate upon complex logic. That is what N-Badges enables.

For example, for MetricsDAO a scenario where:

When creating Marketplaces, Operators want to more flexibly gate participation, so they can create more targeted Marketplaces/Challenges to support the DAO and partners' unique needs, such as…

- Direct to analyst requests (imagine a Marketplace only for Marina)

- Elite analyst only targeting and other cohort targeting (imagine a Marketplace dedicated to Cantina or Pine)

- AND/OR parameters (imagine you need a certain rMETRIC balance AND a certain badge)

It is simple to gate to the precise demographic without the need of running a complex signature engine to sign payloads of authorization.

## Types of Authority Checks

* `NBMultiBalance`: Given a user and a set of access permissions with `mandatory` and `optional` badges from different SFT collections, check if the user has aggregate permission to access an on-chain resource.
    * **Enforces authority as if it is a Hospital Badge.**
    * **Functions as AND/OR configuration.** 
* `NBMultiBalancePoints`: Rather than using `mandatory` badges, this version utilizes summed points based on the points relative to each Badge which enables more socially-defined access control.
    * **Enforces authority as if it is Reputation or a Social Credit Score.**  
    * **Nested logic is expensive however Points enable multi-dimension logic enabling an aggregate-like approach.**
* `NBIDPacked`: Given a loop-index of bitpacked ids, check if the user has permission to access an on-chain resource using only `mandatory` badges that all belong to the same SFT collection.
    * **Enforces authority as if it is a Top Secret Badge.**
    * **The most efficient way to secure critical pieces of the system while maintaing operational flexibility and effectiveness.**