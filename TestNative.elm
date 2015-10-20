module TestNative where

import Path.Current exposing (currPlatform)
import Graphics.Element exposing (show,Element,leftAligned)
import Text

main : Element
main = "currPlatform = " ++ toString currPlatform
  |> Text.fromString
  |> Text.monospace
  |> leftAligned
