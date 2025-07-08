module CDict exposing (..)

{-| A custom dictionary type that allows for keys of any type, as long as
the keys can be converted to and from a `String`. This is useful for
creating dictionaries with keys that are not necessarily strings, such as custom types.
-}

import Dict as ElmDict


type CDict k v
    = CDict (k -> String) (String -> k) (ElmDict.Dict String v)


empty : (k -> String) -> (String -> k) -> CDict k v
empty keyToString stringToKey =
    CDict keyToString stringToKey ElmDict.empty


singleton : (k -> String) -> (String -> k) -> k -> v -> CDict k v
singleton keyToString stringToKey key value =
    CDict keyToString stringToKey (ElmDict.singleton (keyToString key) value)


insert : k -> v -> CDict k v -> CDict k v
insert key value (CDict keyToString stringToKey dict) =
    CDict keyToString stringToKey (ElmDict.insert (keyToString key) value dict)


update : k -> (Maybe v -> Maybe v) -> CDict k v -> CDict k v
update key updateFn (CDict keyToString stringToKey dict) =
    CDict keyToString stringToKey (ElmDict.update (keyToString key) updateFn dict)


remove : k -> CDict k v -> CDict k v
remove key (CDict keyToString stringToKey dict) =
    CDict keyToString stringToKey (ElmDict.remove (keyToString key) dict)


isEmpty : CDict k v -> Bool
isEmpty (CDict _ _ dict) =
    ElmDict.isEmpty dict


member : k -> CDict k v -> Bool
member key (CDict keyToString stringToKey dict) =
    ElmDict.member (keyToString key) dict


get : k -> CDict k v -> Maybe v
get key (CDict keyToString stringToKey dict) =
    ElmDict.get (keyToString key) dict


size : CDict k v -> Int
size (CDict _ _ dict) =
    ElmDict.size dict


keys : CDict k v -> List k
keys (CDict keyToString stringToKey dict) =
    ElmDict.keys dict
        |> List.map stringToKey


values : CDict k v -> List v
values (CDict keyToString stringToKey dict) =
    ElmDict.values dict


toList : CDict k v -> List ( k, v )
toList (CDict keyToString stringToKey dict) =
    ElmDict.toList dict
        |> List.map (\( keyStr, value ) -> ( stringToKey keyStr, value ))


fromList : (k -> String) -> (String -> k) -> List ( k, v ) -> CDict k v
fromList keyToString stringToKey list =
    List.foldl
        (\( key, value ) dict -> insert key value dict)
        (empty keyToString stringToKey)
        list


map : (k -> v -> u) -> CDict k v -> CDict k u
map fn (CDict keyToString stringToKey dict) =
    CDict keyToString stringToKey (ElmDict.map (\str value -> fn (stringToKey str) value) dict)


foldl : (k -> v -> a -> a) -> a -> CDict k v -> a
foldl fn acc (CDict keyToString stringToKey dict) =
    ElmDict.foldl
        (\str value acc2 -> fn (stringToKey str) value acc2)
        acc
        dict


foldr : (k -> v -> a -> a) -> a -> CDict k v -> a
foldr fn acc (CDict keyToString stringToKey dict) =
    ElmDict.foldr
        (\str value acc2 -> fn (stringToKey str) value acc2)
        acc
        dict


filter : (k -> v -> Bool) -> CDict k v -> CDict k v
filter predicate (CDict keyToString stringToKey dict) =
    CDict keyToString stringToKey (ElmDict.filter (\str value -> predicate (stringToKey str) value) dict)


partition : (k -> v -> Bool) -> CDict k v -> ( CDict k v, CDict k v )
partition predicate (CDict keyToString stringToKey dict) =
    let
        ( trueDict, falseDict ) =
            ElmDict.partition (\str value -> predicate (stringToKey str) value) dict
    in
    ( CDict keyToString stringToKey trueDict
    , CDict keyToString stringToKey falseDict
    )


union : CDict k v -> CDict k v -> CDict k v
union (CDict keyToString stringToKey dict1) (CDict _ _ dict2) =
    CDict keyToString stringToKey (ElmDict.union dict1 dict2)


intersect : CDict k v -> CDict k v -> CDict k v
intersect (CDict keyToString stringToKey dict1) (CDict _ _ dict2) =
    CDict keyToString stringToKey (ElmDict.intersect dict1 dict2)


diff : CDict k v -> CDict k v -> CDict k v
diff (CDict keyToString stringToKey dict1) (CDict _ _ dict2) =
    CDict keyToString stringToKey (ElmDict.diff dict1 dict2)
