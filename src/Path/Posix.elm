module Path.Posix (
    -- * Separator predicates
    pathSeparator, pathSeparators, isPathSeparator,
    extSeparator, isExtSeparator,

    -- * Extension functions
    splitExtension,
    takeExtension, replaceExtension, dropExtension, addExtension, hasExtension,
    splitExtensions, dropExtensions, takeExtensions,
    -- (<.>), (-<.>),

    -- * Filename\/directory functions
    splitFileName,
    takeFileName, replaceFileName, dropFileName,
    takeBaseName, replaceBaseName,
    takeDirectory, replaceDirectory,
    combine, (</>),
    splitPath, joinPath,

    -- * Trailing slash functions
    hasTrailingPathSeparator,
    addTrailingPathSeparator,
    dropTrailingPathSeparator
    ) where

{-|
Specialized path manipulation functions for working with Posix paths. For documentation on the API refer to 'Path.Generic'.

Reexports all functions from the 'Path.Generic' module, specialized to Posix paths.

Since operator reexport does not seem to work, <.> and -<.> have to be imported from the Generic module directly.

# Separator predicates
@docs pathSeparator, pathSeparators, isPathSeparator, extSeparator, isExtSeparator

# Extension functions
@docs splitExtension, takeExtension, replaceExtension, dropExtension, addExtension, hasExtension, splitExtensions, dropExtensions, takeExtensions

# Filename/directory functions
@docs splitFileName, takeFileName, replaceFileName, dropFileName, takeBaseName, replaceBaseName, takeDirectory, replaceDirectory, combine, splitPath, joinPath

# Trailing slash functions
@docs hasTrailingPathSeparator, addTrailingPathSeparator, dropTrailingPathSeparator

# Specialized operators
@docs (</>), takeFileName
-}


import Path.Generic as Generic

infixr 5  </>

currPlatform : Generic.Platform
currPlatform = Generic.Posix


{-|
  Operator Version of 'combine'
-}
(</>) : String -> String -> String
(</>) = combine

{-|
The character that separates directories. In the case where more than
one character is possible, `pathSeparator` is the 'ideal' one.

    Windows: pathSeparator == '\\'
    Posix:   pathSeparator ==  '/'
    isPathSeparator pathSeparator
-}
pathSeparator : String
pathSeparator = Generic.pathSeparator currPlatform

{-|
The list of all possible separators.

    Windows: pathSeparators == ['\\', '/']
    Posix:   pathSeparators == ['/']
    pathSeparator `elem` pathSeparators
-}
pathSeparators : List String
pathSeparators = Generic.pathSeparators currPlatform

{-|
Rather than using `== pathSeparator`, use this. Test if somethin is a path separator.

    isPathSeparator a == (a `elem` pathSeparators)
-}
isPathSeparator : String -> Bool
isPathSeparator = Generic.isPathSeparator currPlatform


{-|
File extension character

    extSeparator == '.'
-}
extSeparator : String
extSeparator = Generic.extSeparator


{-|
Is the character an extension character?

    isExtSeparator a == (a == extSeparator)
-}
isExtSeparator : String -> Bool
isExtSeparator = Generic.isExtSeparator


{-|
Split on the extension. `addExtension` is the inverse.

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
splitExtension = Generic.splitExtension


{-|
Get the extension of a file, returns "" for no extension, .ext otherwise.

    takeExtension "/directory/path.ext" == ".ext"
    takeExtension x == snd (splitExtension x)
    Valid x => takeExtension (addExtension x "ext") == ".ext"
    Valid x => takeExtension (replaceExtension x "ext") == ".ext"
-}
takeExtension : String -> String
takeExtension = Generic.takeExtension


{-|
Set the extension of a file, overwriting one if already present, equivalent to `-<.>`.

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
replaceExtension = Generic.replaceExtension


{-|
Operator version of `replaceExtension`
-}
(-<.>) : String -> String -> String
(-<.>) = replaceExtension


{-|
Remove last extension, and the "." preceding it.

    dropExtension "/directory/path.ext" == "/directory/path"
    dropExtension x == fst (splitExtension x)
-}
dropExtension : String -> String
dropExtension = Generic.dropExtension


{-|
Add an extension, even if there is already one there, equivalent to `<.>`.

    addExtension "/directory/path" "ext" == "/directory/path.ext"
    addExtension "file.txt" "bib" == "file.txt.bib"
    addExtension "file." ".bib" == "file..bib"
    addExtension "file" ".bib" == "file.bib"
    addExtension "/" "x" == "/.x"
    Valid x => takeFileName (addExtension (addTrailingPathSeparator x) "ext") == ".ext"
    Windows: addExtension "\\\\share" ".txt" == "\\\\share\\.txt"
-}
addExtension : String -> String -> String
addExtension = Generic.addExtension


{-|
Operator version of `addExtension`
-}
(<.>) : String -> String -> String
(<.>) = addExtension


{-|
Does the given filename have an extension?

    hasExtension "/directory/path.ext" == True
    hasExtension "/directory/path" == False
    ull (takeExtension x) == not (hasExtension x)
-}
hasExtension : String -> Bool
hasExtension = Generic.hasExtension


{-|
Split on all extensions.

    splitExtensions "/directory/path.ext" == ("/directory/path",".ext")
    splitExtensions "file.tar.gz" == ("file",".tar.gz")
    uncurry (++) (splitExtensions x) == x
    Valid x => uncurry addExtension (splitExtensions x) == x
    splitExtensions "file.tar.gz" == ("file",".tar.gz")
-}
splitExtensions : String -> (String, String)
splitExtensions = Generic.splitExtensions


{-|
Get all extensions.

    takeExtensions "/directory/path.ext" == ".ext"
    takeExtensions "file.tar.gz" == ".tar.gz"
-}
takeExtensions : String -> String
takeExtensions = Generic.takeExtensions


{-|
Drop all extensions.

    dropExtensions "/directory/path.ext" == "/directory/path"
    dropExtensions "file.tar.gz" == "file"
    not <| hasExtension <| dropExtensions x
    not <| any isExtSeparator <| takeFileName <| dropExtensions x
-}
dropExtensions : String -> String
dropExtensions = Generic.dropExtensions


{-|
Operations on a filepath, as a list of directories

Split a filename into directory and file. `combine` is the inverse.
The first component will often end with a trailing slash.

    splitFileName "/directory/file.ext" == ("/directory/","file.ext")
    Valid x => isValid (fst (splitFileName x))
    splitFileName "file/bob.txt" == ("file/", "bob.txt")
    splitFileName "file/" == ("file/", "")
    splitFileName "bob" == ("", "bob")
    Posix:   splitFileName "/" == ("/","")
-}
splitFileName : String -> (String, String)
splitFileName = Generic.splitFileName currPlatform

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
takeFileName : String -> String
takeFileName = Generic.takeFileName currPlatform


{-|
Set the filename.

    replaceFileName "/directory/other.txt" "file.ext" == "/directory/file.ext"
    Valid x => replaceFileName x (takeFileName x) == x
-}
replaceFileName : String -> String -> String
replaceFileName = Generic.replaceFileName currPlatform


{-|
Drop the filename. Unlike `takeDirectory`, this function will leave
a trailing path separator on the directory.

    dropFileName "/directory/file.ext" == "/directory/"
    dropFileName x == fst (splitFileName x)
-}
dropFileName : String -> String
dropFileName = Generic.dropFileName currPlatform


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
takeBaseName : String -> String
takeBaseName = Generic.takeBaseName currPlatform


{-|
Set the base name.

    replaceBaseName "/directory/other.ext" "file" == "/directory/file.ext"
    replaceBaseName "file/test.txt" "bob" == "file/bob.txt"
    replaceBaseName "fred" "bill" == "bill"
    replaceBaseName "/dave/fred/bob.gz.tar" "new" == "/dave/fred/new.tar"
    Valid x => replaceBaseName x (takeBaseName x) == x
-}
replaceBaseName : String -> String -> String
replaceBaseName = Generic.replaceBaseName currPlatform


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
takeDirectory : String -> String
takeDirectory = Generic.takeDirectory currPlatform


{-|
Set the directory, keeping the filename the same.

    replaceDirectory "root/file.ext" "/directory/" == "/directory/file.ext"
    Valid x => replaceDirectory x (takeDirectory x) `equalFilePath` x
-}
replaceDirectory : String -> String -> String
replaceDirectory = Generic.replaceDirectory currPlatform


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
combine : String -> String -> String
combine = Generic.combine currPlatform


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
splitPath : String -> List String
splitPath = Generic.splitPath currPlatform


{-|
Join path elements back together.

    joinPath ["/","directory/","file.ext"] == "/directory/file.ext"
    Valid x => joinPath (splitPath x) == x
    joinPath [] == ""
    Posix: joinPath ["test","file","path"] == "test/file/path"
-}
joinPath : List String -> String
joinPath =Generic.joinPath currPlatform


{-|
Is an item either a directory or the last character a path separator?

    hasTrailingPathSeparator "test" == False
    hasTrailingPathSeparator "test/" == True
-}
hasTrailingPathSeparator : String -> Bool
hasTrailingPathSeparator = Generic.hasTrailingPathSeparator currPlatform


{-|
Add a trailing file path separator if one is not already present.

    hasTrailingPathSeparator (addTrailingPathSeparator x)
    hasTrailingPathSeparator x ==> addTrailingPathSeparator x == x
    Posix:    addTrailingPathSeparator "test/rest" == "test/rest/"
-}
addTrailingPathSeparator : String -> String
addTrailingPathSeparator = Generic.addTrailingPathSeparator currPlatform


{-|
Remove any trailing path separators

    dropTrailingPathSeparator "file/test/" == "file/test"
              dropTrailingPathSeparator "/" == "/"
    Windows:  dropTrailingPathSeparator "\\" == "\\"
-}
dropTrailingPathSeparator : String -> String
dropTrailingPathSeparator = Generic.dropTrailingPathSeparator currPlatform
