-- Copyright 2021 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Data.Functor.Const (Const(..))

import Test.Framework (defaultMain)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck ((===), forAllBlind, arbitrary)

import Data.Vec.Short (rev)

import Control.Batching

main :: IO ()
main = defaultMain
  [ testProperty "deferred map" $ forAllBlind (arbitrary @(Int -> Int)) $
      \f xs ->
        runBatching_ (fmap f) (traverse request xs) === map f xs

  , testProperty "deferred map2" $ forAllBlind (arbitrary @(Int -> Int)) $
      \f xss ->
        runBatching_ (fmap f) (traverse batchRequest xss) ===
          map (map f) xss

  , testProperty "roundabout reverse" $ \ (xs :: [Int]) ->
      runBatching_ rev (traverse request xs) === reverse xs

  , testProperty "list?" $ \ (xs :: [Int]) ->
      runBatching (\rqs -> [rqs, rev rqs]) (traverse request xs) ===
        [xs, reverse xs]

  , testProperty "silliness" $ \ (xs :: [Int]) ->
      runBatching (\rqs -> Const (length rqs)) (traverse request xs) ===
        Const (length xs)
  ]
