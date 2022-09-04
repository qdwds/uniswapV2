export const isArray = (type:any):boolean => Object.prototype.toString.call(type) == "[object Array]";
export const isNumber = (type:any):boolean => Object.prototype.toString.call(type) == "[object Number]";
export const isString = (type:any):boolean => Object.prototype.toString.call(type) == "[object String]";
