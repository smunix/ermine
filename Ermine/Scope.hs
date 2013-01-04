{-# LANGUAGE Rank2Types #-}
--------------------------------------------------------------------
-- |
-- Module    :  Ermine.Scope
-- Copyright :  (c) Edward Kmett
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: portable
--------------------------------------------------------------------
module Ermine.Scope
  ( hoistScope
  , bitraverseScope
  , bound
  , free
  ) where

import Bound
import Control.Applicative
import Control.Lens
import Data.Bitraversable

-- | Lift a natural transformation from @f@ to @g@ into one between scopes.
hoistScope :: Functor f => (forall x. f x -> g x) -> Scope b f a -> Scope b g a
hoistScope t (Scope b) = Scope $ t (fmap t <$> b)
{-# INLINE hoistScope #-}

-- | This allows you to 'bitraverse' a 'Scope'.
bitraverseScope :: (Bitraversable t, Applicative f) => (k -> f k') -> (a -> f a') -> Scope b (t k) a -> f (Scope b (t k') a')
bitraverseScope f g = fmap Scope . bitraverse f (traverse (bitraverse f g)) . unscope
{-# INLINE bitraverseScope #-}

bound :: Prism (Var a c) (Var b c) a b
bound = prism B $ \ t -> case t of
  B b -> Right b
  F c -> Left (F c)

free :: Prism (Var c a) (Var c b) a b
free = prism F $ \ t -> case t of
  B c -> Left (B c)
  F b -> Right b