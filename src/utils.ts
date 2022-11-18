import fs from "fs";

export function getFiles(dir: string) {
    var files: string[] = [];
    var list = fs.readdirSync(dir);
    list.forEach(function(file) {
        file = dir + "/" + file;
        var stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            files = files.concat(getFiles(file));
        } else {
            files.push(file);
        }
    });

    return files
        .map(file => file.startsWith("./") ? file.substring(2) : file);
}