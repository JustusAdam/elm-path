module TestNative where

import Path.Current exposing (currPlatform)
import Graphics.Element exposing (show,Element,leftAligned)
import Text

main : Element
main = leftAligned << Text.monospace << Text.fromString <|
  "currPlatform = " ++ toString currPlatform
