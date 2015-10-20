var sanitize = function sanitize(record) {
    var spaces = Array.prototype.slice.call(arguments, 1);
    return spaces.reduce(function (r, space) {
        return (function () {
            r[space] ? void 0 : r[space] = {};
            return r[space];
        })();
    }, record);
};
var make = function make(localRuntime) {
    return (function () {
        sanitize(localRuntime, 'Native', 'CurrPlatform');
        return localRuntime.Native.CurrPlatform.values ? localRuntime.Native.CurrPlatform.values : localRuntime.Native.CurrPlatform.values = { 'navigatorPlatform': navigator.platform };
    })();
};
sanitize(Elm, 'Native', 'CurrPlatform');
Elm.Native.CurrPlatform.make = make;
