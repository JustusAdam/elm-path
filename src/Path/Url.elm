module Path.Url (
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
Specialized path manipulation functions for working with filepaths as found on the web. For documentation on the API refer to 'Path.Generic'.

Reexports all functions from the 'Path.Generic' module, specialized to web related paths.

Since operator reexport does not seem to work, <.> and -<.> have to be imported from the Generic module directly.

# Specialized operators
@docs (</>)
-}

import Path.Generic as Generic


infixr 5  </>

currPlatform = Generic.Url


pathSeparator = Generic.pathSeparator currPlatform
pathSeparators = Generic.pathSeparators currPlatform
isPathSeparator = Generic.isPathSeparator currPlatform
extSeparator = Generic.extSeparator
isExtSeparator = Generic.extSeparator

splitExtension = Generic.splitExtension
takeExtension = Generic.takeExtension
replaceExtension = Generic.replaceExtension
-- (-<.>) : String -> String -> String
-- (-<.>) = Generic.-<.>
dropExtension = Generic.dropExtension
addExtension = Generic.addExtension
-- (<.>) : String -> String -> String
-- (<.>) = Generic.<.>
hasExtension = Generic.hasExtension
splitExtensions = Generic.splitExtensions
dropExtensions = Generic.dropExtensions
takeExtensions = Generic.takeExtensions

splitFileName = Generic.splitFileName currPlatform
takeFileName = Generic.takeFileName currPlatform
replaceFileName = Generic.replaceFileName currPlatform
dropFileName = Generic.dropFileName currPlatform
takeBaseName = Generic.takeBaseName currPlatform
replaceBaseName = Generic.replaceBaseName currPlatform
takeDirectory = Generic.takeDirectory currPlatform
replaceDirectory = Generic.replaceDirectory currPlatform
combine = Generic.combine currPlatform
splitPath = Generic.splitPath currPlatform
joinPath = Generic.joinPath currPlatform

hasTrailingPathSeparator = Generic.hasTrailingPathSeparator currPlatform
addTrailingPathSeparator = Generic.addTrailingPathSeparator currPlatform
dropTrailingPathSeparator = Generic.dropTrailingPathSeparator currPlatform

{-|
  Operator Version of 'combine'
-}
(</>) : String -> String -> String
(</>) = combine
