
--------------------------------------------------------------------
-- |
-- Module    :  Ermine.Builtin.Pat
-- Copyright :  (c) Edward Kmett, Dan Doel 2012-2013
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
-- Smart builders for convenient building of patterns.
--------------------------------------------------------------------

module Ermine.Builtin.Pat ( P(..)
                          , varp
                          , _p
                          , strictp
                          , lazyp
                          , asp
                          , primp
                          , alt
                          ) where

import Bound
import Control.Applicative
import Data.List as List
import Ermine.Syntax.Pat
import Ermine.Syntax.Prim

-- | Smart Pattern
data P a = P { pattern :: Pat (), bindings :: [a] } deriving Show

-- | A pattern that binds a variable.
varp :: a -> P a
varp a = P VarP [a]

-- | A wildcard pattern that ignores its argument
_p :: P a
_p = P WildcardP []

-- | A strict (bang) pattern
strictp :: P a -> P a
strictp (P p bs) = P (StrictP p) bs

-- | A lazy (irrefutable) pattern
lazyp :: P a -> P a
lazyp (P p bs) = P (LazyP p) bs

-- | An as @(\@)@ pattern.
asp :: a -> P a -> P a
asp a (P p as) = P (AsP p) (a:as)

-- | A pattern that matches a primitive expression.
primp :: Prim -> [P a] -> P a
primp g ps = P (PrimP g (pattern <$> ps)) (ps >>= bindings)

-- | smart alt constructor
alt :: (Monad f, Eq a) => P a -> f a -> Alt () f a
alt (P p as) t = Alt p (abstract (`List.elemIndex` as) t)