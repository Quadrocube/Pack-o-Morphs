function assert(condition, message) {
    if (!condition) {
        message = message || "Assertion failed";
        if (typeof Error !== "undefined") {
            throw new Error(message);
        }
        throw message; // Fallback
    }
}

function logg(object) {
    var output = '';
    for (var property in object) {
        output += property + ': ' + object[property]+'; ';
    }
    console.log(output);
}