(defn- sanitize [record & spaces]
  (spaces.reduce (fn [r space] (do
    (if (aget r space) nil (set! (aget r space) {}))
    (aget r space)))
  record))

(defn- currPlatform [windows posix]
  (windows))

(defn- make [localRuntime]
  (do (sanitize localRuntime :Native :Path)
      (if localRuntime.Native.Path.values
          localRuntime.Native.Path.values
          (set! localRuntime.Native.Path.values {
            :currPlatform (F2 currPlatform) }))))

(sanitize Elm :Native :Path)
(set! Elm.Native.Path.make make)
