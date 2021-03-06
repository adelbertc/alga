module Algebra.Graph.TopSort (
    TopSort, isTopSort, topSort, vertexSet
    ) where

import qualified Data.Graph as Std
import qualified Data.Map.Strict as Map
import Data.Ord
import qualified Data.Set as Set
import           Data.Set (Set)

import Algebra.Graph
import Algebra.Graph.AdjacencyMap

newtype TopSort a = TS { fromTopSort :: AdjacencyMap a } deriving (Num, Show)

instance Ord a => Eq (TopSort a) where
    TS x == TS y = topSort x == topSort y

vertexSet :: TopSort a -> Set a
vertexSet = Map.keysSet . adjacencyMap . fromTopSort

topSort :: Ord a => AdjacencyMap a -> Maybe [a]
topSort x = if isTopSort x result then Just result else Nothing
  where
    (g, r) = toKLvia Down (\(Down v) -> v) x
    result = map r $ Std.topSort g

isTopSort :: forall a. Ord a => AdjacencyMap a -> [a] -> Bool
isTopSort x = go Set.empty
  where
    go :: Set a -> [a] -> Bool
    go seen []     = seen == Map.keysSet (adjacencyMap x)
    go seen (v:vs) = let newSeen = seen `seq` Set.insert v seen
        in postset v x `Set.intersection` newSeen == Set.empty && go newSeen vs

-- To be derived automatically using GeneralizedNewtypeDeriving in GHC 8.2
instance Ord a => Graph (TopSort a) where
    type Vertex (TopSort a) = a
    empty       = TS empty
    vertex      = TS . vertex
    overlay x y = TS $ fromTopSort x `overlay` fromTopSort y
    connect x y = TS $ fromTopSort x `connect` fromTopSort y
