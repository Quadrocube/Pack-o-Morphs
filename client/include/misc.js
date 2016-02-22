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

function MyQueue () {
    this.carry = [];
    this.length = function () {
        return this.carry.length;
    }
    this.push = function (val) {
        this.carry.push(val);
    };
    this.pop = function () {
        this.carry.splice(0,1);
    };
    this.remove_by_value = function (val) {
        var found = undefined;
        for (i in this.carry) {
            if (this.carry[i] === val) {
                found = i;
            }
        }
        if (found !== undefined) {
            this.carry.splice(found, 1);
        }
    };
}