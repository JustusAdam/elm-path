module Path.Generic (
    -- * Platforms
    Platform(Windows, Posix, Url),

    -- * Separator predicates
    pathSeparator, pathSeparators, isPathSeparator,
    extSeparator, isExtSeparator,

    -- * Extension functions
    splitExtension,
    takeExtension, replaceExtension, (-<.>), dropExtension, addExtension, hasExtension, (<.>),
    splitExtensions, dropExtensions, takeExtensions,

    -- * Filename\/directory functions
    splitFileName,
    takeFileName, replaceFileName, dropFileName,
    takeBaseName, replaceBaseName,
    takeDirectory, replaceDirectory,
    combine,
    splitPath, joinPath,

    -- * Trailing slash functions
    hasTrailingPathSeparator,
    addTrailingPathSeparator,
    dropTrailingPathSeparator
    ) where
{-|
Functions for working with paths, parameterized over the platform.

If you use the specialized versions from 'Path.Windows', 'Path.Posix' or 'Path.Url' the 'Platform' parameter is to be omitted.

# Platforms
@docs Platform

# Separator predicates
@docs pathSeparator, pathSeparators, isPathSeparator, extSeparator, isExtSeparator

# Extension functions
@dosc splitExtension, takeExtension, replaceExtension, (-<.>), dropExtension, addExtension, hasExtension, (<.>), splitExtensions, dropExtensions, takeExtensions

# Filename/directory functions
@docs splitFileName, takeFileName, replaceFileName, dropFileName, takeBaseName, replaceBaseName, takeDirectory, replaceDirectory, combine, splitPath, joinPath

# Trailing slash functions
@docs hasTrailingPathSeparator, addTrailingPathSeparator, dropTrailingPathSeparator
-}


import String


infixr 7  <.>
infixr 7 -<.>


{-|
Available platforms for path manipulations.

Windows, Posix are relatively self explanatory

Url is specialized to filepaths as used on the web
-}
type Platform
  = Posix
  | Windows
  | Url


{-|
The character that separates directories. In the case where more than
one character is possible, 'pathSeparator' is the \'ideal\' one.

    Windows: pathSeparator == '\\'
    Posix:   pathSeparator ==  '/'
    isPathSeparator pathSeparator
-}
pathSeparator : Platform -> String
pathSeparator platform =
  case platform of
    Windows -> "\\\\"
    _ -> "/"

{-|
The list of all possible separators.

    Windows: pathSeparators == ['\\', '/']
    Posix:   pathSeparators == ['/']
    pathSeparator `elem` pathSeparators
-}
pathSeparators : Platform -> List String
pathSeparators platform =
  case platform of
    Windows -> ["/", "\\\\"]
    _ -> ["/"]

{-|
Rather than using @(== 'pathSeparator')@, use this. Test if somethin is a path separator.

    isPathSeparator a == (a `elem` pathSeparators)
-}
isPathSeparator : Platform -> String -> Bool
isPathSeparator platform = flip List.member (pathSeparators platform)


{-|
File extension character

    extSeparator == '.'
-}
extSeparator : String
extSeparator = "."


{-|
Is the character an extension character?

    isExtSeparator a == (a == extSeparator)
-}
isExtSeparator : String -> Bool
isExtSeparator = (==) extSeparator


{-|
Split on the extension. 'addExtension' is the inverse.

    splitExtension "/directory/path.ext" == ("/directory/path",".ext")
    uncurry (++) (splitExtension x) == x
    Valid x => uncurry addExtension (splitExtension x) == x
    splitExtension "file.txt" == ("file",".txt")
    splitExtension "file" == ("file","")
    splitExtension "file/file.txt" == ("file/file",".txt")
    splitExtension "file.txt/boris" == ("file.txt/boris","")
    splitExtension "file.txt/boris.ext" == ("file.txt/boris",".ext")
    splitExtension "file/path.txt.bob.fred" == ("file/path.txt.bob",".fred")
    splitExtension "file/path.txt/" == ("file/path.txt/","")
-}
splitExtension : String -> (String, String)
splitExtension path =
  case String.reverse path |> String.split extSeparator of
    [] -> ("", "")
    [a] -> (String.reverse a, "")
    (x::xs) -> (String.reverse <| String.join extSeparator xs, extSeparator ++ String.reverse x)


{-|
Get the extension of a file, returns @\"\"@ for no extension, @.ext@ otherwise.

    takeExtension "/directory/path.ext" == ".ext"
    takeExtension x == snd (splitExtension x)
    Valid x => takeExtension (addExtension x "ext") == ".ext"
    Valid x => takeExtension (replaceExtension x "ext") == ".ext"
-}
takeExtension : String -> String
takeExtension = splitExtension >> snd


{-|
Set the extension of a file, overwriting one if already present, equivalent to '-<.>'.

    replaceExtension "/directory/path.txt" "ext" == "/directory/path.ext"
    replaceExtension "/directory/path.txt" ".ext" == "/directory/path.ext"
    replaceExtension "file.txt" ".bob" == "file.bob"
    replaceExtension "file.txt" "bob" == "file.bob"
    replaceExtension "file" ".bob" == "file.bob"
    replaceExtension "file.txt" "" == "file"
    replaceExtension "file.fred.bob" "txt" == "file.fred.txt"
    replaceExtension x y == addExtension (dropExtension x) y
-}
replaceExtension : String -> String -> String
replaceExtension path ext =
  splitExtension path |> fst |> (flip (++) <| normalizeExt ext)


-- | Operator version of 'replaceExtension'
(-<.>) : String -> String -> String
(-<.>) = replaceExtension


{-|
Remove last extension, and the \".\" preceding it.

    dropExtension "/directory/path.ext" == "/directory/path"
    dropExtension x == fst (splitExtension x)
-}
dropExtension : String -> String
dropExtension = splitExtension >> fst


{-|
Add an extension, even if there is already one there, equivalent to '<.>'.

    addExtension "/directory/path" "ext" == "/directory/path.ext"
    addExtension "file.txt" "bib" == "file.txt.bib"
    addExtension "file." ".bib" == "file..bib"
    addExtension "file" ".bib" == "file.bib"
    addExtension "/" "x" == "/.x"
    Valid x => takeFileName (addExtension (addTrailingPathSeparator x) "ext") == ".ext"
    Windows: addExtension "\\\\share" ".txt" == "\\\\share\\.txt"
-}
addExtension : String -> String -> String
addExtension path = (++) path << normalizeExt


-- | Operator version of 'addExtension'
(<.>) : String -> String -> String
(<.>) = addExtension


{-|
Does the given filename have an extension?

    hasExtension "/directory/path.ext" == True
    hasExtension "/directory/path" == False
    ull (takeExtension x) == not (hasExtension x)
-}
hasExtension : String -> Bool
hasExtension = splitExtension >> snd >> String.isEmpty


{-|
Split on all extensions.

    splitExtensions "/directory/path.ext" == ("/directory/path",".ext")
    splitExtensions "file.tar.gz" == ("file",".tar.gz")
    uncurry (++) (splitExtensions x) == x
    Valid x => uncurry addExtension (splitExtensions x) == x
    splitExtensions "file.tar.gz" == ("file",".tar.gz")
-}
splitExtensions : String -> (String, String)
splitExtensions path =
  case String.split extSeparator path of
    [] -> ("", "")
    [a] -> (a, "")
    (x::xs) -> (x, String.join extSeparator xs)


{-|
Get all extensions.

    takeExtensions "/directory/path.ext" == ".ext"
    takeExtensions "file.tar.gz" == ".tar.gz"
-}
takeExtensions : String -> String
takeExtensions = splitExtensions >> snd


{-|
Drop all extensions.

    dropExtensions "/directory/path.ext" == "/directory/path"
    dropExtensions "file.tar.gz" == "file"
    not <| hasExtension <| dropExtensions x
    not <| any isExtSeparator <| takeFileName <| dropExtensions x
-}
dropExtensions : String -> String
dropExtensions = splitExtensions >> fst


{-|
Operations on a filepath, as a list of directories

Split a filename into directory and file. 'combine' is the inverse.
The first component will often end with a trailing slash.

    splitFileName "/directory/file.ext" == ("/directory/","file.ext")
    Valid x => isValid (fst (splitFileName x))
    splitFileName "file/bob.txt" == ("file/", "bob.txt")
    splitFileName "file/" == ("file/", "")
    splitFileName "bob" == ("", "bob")
    Posix:   splitFileName "/" == ("/","")
-}
splitFileName : Platform -> String -> (String, String)
splitFileName platform path =
  case String.split (pathSeparator platform) <| String.reverse path of
    [] -> ("", "")
    [a] -> ("",  a)
    (x::xs) -> (String.reverse <| String.join (pathSeparator platform) (""::xs), String.reverse x)

{-|
Get the file name.

    takeFileName "/directory/file.ext" == "file.ext"
    takeFileName "test/" == ""
    takeFileName x `isSuffixOf` x
    takeFileName x == snd (splitFileName x)
    Valid x => takeFileName (replaceFileName x "fred") == "fred"
    Valid x => takeFileName (x </> "fred") == "fred"
    Valid x => isRelative (takeFileName x)
-}
takeFileName : Platform -> String -> String
takeFileName platform = splitFileName platform >> snd


{-|
Set the filename.

    replaceFileName "/directory/other.txt" "file.ext" == "/directory/file.ext"
    Valid x => replaceFileName x (takeFileName x) == x
-}
replaceFileName : Platform -> String -> String -> String
replaceFileName platform path = (++) <| dropFileName platform path


{-|
Drop the filename. Unlike 'takeDirectory', this function will leave
a trailing path separator on the directory.

    dropFileName "/directory/file.ext" == "/directory/"
    dropFileName x == fst (splitFileName x)
-}
dropFileName : Platform -> String -> String
dropFileName platform = splitFileName platform >> fst


{-|
Get the base name, without an extension or path.

    takeBaseName "/directory/file.ext" == "file"
    takeBaseName "file/test.txt" == "test"
    takeBaseName "dave.ext" == "dave"
    takeBaseName "" == ""
    takeBaseName "test" == "test"
    takeBaseName (addTrailingPathSeparator x) == ""
    takeBaseName "file/file.tar.gz" == "file.tar"
-}
takeBaseName : Platform -> String -> String
takeBaseName platform = takeFileName platform >> dropExtension


{-|
Set the base name.

    replaceBaseName "/directory/other.ext" "file" == "/directory/file.ext"
    replaceBaseName "file/test.txt" "bob" == "file/bob.txt"
    replaceBaseName "fred" "bill" == "bill"
    replaceBaseName "/dave/fred/bob.gz.tar" "new" == "/dave/fred/new.tar"
    Valid x => replaceBaseName x (takeBaseName x) == x
-}
replaceBaseName : Platform -> String -> String -> String
replaceBaseName platform path new =
  let
    (dir, old) = splitFileName platform path
    (_, ext) = splitExtension old
  in
    dir ++ new ++ ext


{-|
Get the directory name, move up one level.

              takeDirectory "/directory/other.ext" == "/directory"
              takeDirectory x `isPrefixOf` x || takeDirectory x == "."
              takeDirectory "foo" == "."
              takeDirectory "/" == "/"
              takeDirectory "/foo" == "/"
              takeDirectory "/foo/bar/baz" == "/foo/bar"
              takeDirectory "/foo/bar/baz/" == "/foo/bar/baz"
              takeDirectory "foo/bar/baz" == "foo/bar"
    Windows:  takeDirectory "foo\\bar" == "foo"
    Windows:  takeDirectory "foo\\bar\\\\" == "foo\\bar"
-}
takeDirectory : Platform -> String -> String
takeDirectory platform = splitFileName platform >> fst


{-|
Set the directory, keeping the filename the same.

    replaceDirectory "root/file.ext" "/directory/" == "/directory/file.ext"
    Valid x => replaceDirectory x (takeDirectory x) `equalFilePath` x
-}
replaceDirectory : Platform -> String -> String -> String
replaceDirectory platform path = flip (++) (takeFileName platform path)


{-|
Combine two paths, if the second path starts with a path separator then it returns the second.

    Valid x => combine (takeDirectory x) (takeFileName x) `equalFilePath` x

Combined:

    Posix:   combine "/" "test" == "/test"
    Posix:   combine "home" "bob" == "home/bob"
    Posix:   combine "x:" "foo" == "x:/foo"
    Windows: combine "C:\\foo" "bar" == "C:\\foo\\bar"
    Windows: combine "home" "bob" == "home\\bob"
-}
combine : Platform -> String -> String -> String
combine platform path1 path2 =
  if List.any (flip String.startsWith path2) (pathSeparators platform)
    then path2
    else
      case (path1, path2) of
        ("", b) -> b
        (a, "") -> a
        (a, b) ->
          if isPathSeparator platform a
            then a ++b
            else addTrailingPathSeparator platform a ++ b


{-|
Split a path by the directory separator.

    splitPath "/directory/file.ext" == ["/","directory/","file.ext"]
    concat (splitPath x) == x
    splitPath "test//item/" == ["test//","item/"]
    splitPath "test/item/file" == ["test/","item/","file"]
    splitPath "" == []
    Windows: splitPath "c:\\test\\path" == ["c:\\","test\\","path"]
    Posix:   splitPath "/file/test" == ["/","file/","test"]
-}
splitPath : Platform -> String -> List String
splitPath platform path =
  case String.split (pathSeparator platform) path of
    (x::xs) -> if String.isEmpty x then pathSeparator platform::xs else x::xs
    a -> a


{-|
Join path elements back together.

    joinPath ["/","directory/","file.ext"] == "/directory/file.ext"
    Valid x => joinPath (splitPath x) == x
    joinPath [] == ""
    Posix: joinPath ["test","file","path"] == "test/file/path"
-}
joinPath : Platform -> List String -> String
joinPath = flip List.foldr "" << combine


{-|
Is an item either a directory or the last character a path separator?

    hasTrailingPathSeparator "test" == False
    hasTrailingPathSeparator "test/" == True
-}
hasTrailingPathSeparator : Platform -> String -> Bool
hasTrailingPathSeparator platform path =
  List.any (flip String.endsWith path) (pathSeparators platform) && not (isPathSeparator platform path)


{-|
Add a trailing file path separator if one is not already present.

    hasTrailingPathSeparator (addTrailingPathSeparator x)
    hasTrailingPathSeparator x ==> addTrailingPathSeparator x == x
    Posix:    addTrailingPathSeparator "test/rest" == "test/rest/"
-}
addTrailingPathSeparator : Platform -> String -> String
addTrailingPathSeparator platform path =
  if hasTrailingPathSeparator platform path
    then path
    else path ++ pathSeparator platform


{-|
Remove any trailing path separators

    dropTrailingPathSeparator "file/test/" == "file/test"
              dropTrailingPathSeparator "/" == "/"
    Windows:  dropTrailingPathSeparator "\\" == "\\"
-}
dropTrailingPathSeparator : Platform -> String -> String
dropTrailingPathSeparator platform path =
  if hasTrailingPathSeparator platform path
    then
      Maybe.withDefault path <|
         Maybe.map (List.reverse >> joinPath platform) (splitPath platform path |> List.reverse |> List.tail)
    else path


-- Internal

normalizeExt ext =
  if String.startsWith extSeparator ext
    then ext
    else extSeparator ++ ext
