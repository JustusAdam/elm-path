(defn- sanitize [record & spaces]
  (spaces.reduce (fn [r space] (do
    (if (aget r space) nil (set! (aget r space) {}))
    (aget r space)))
  record))

(defn- make [localRuntime]
  (do (sanitize localRuntime :Native :CurrPlatform)
      (if       localRuntime.Native.CurrPlatform.values
                localRuntime.Native.CurrPlatform.values
          (set! localRuntime.Native.CurrPlatform.values {
            :navigatorPlatform navigator.platform }))))

(sanitize Elm :Native :CurrPlatform)
(set! Elm.Native.CurrPlatform.make make)
