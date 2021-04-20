# batching

An Applicative Functor deferring actions to run in a batch later.

## Disclaimer

This is not an officially supported Google product.

## Overview

This provides the type Batching, an Applicative which defers request-response
exchanges of a fixed type, to be performed in a single batch.  This means you
can write code that appears to issue requests and immediately receive their
responses, but process the requests jointly all at once.

This allows for interaction between the requests; for example:

```
runIdentity $ runBatching
  (\_ v -> Identity $ show <$> vsort v)
  (liftA3 (\x y z -> x ++ y ++ z) (request 2) (request 10) (request 1))
===
"1210"
```
