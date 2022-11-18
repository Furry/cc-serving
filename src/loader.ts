import fs from "fs";
import path from "path";
// @ts-ignore
import luamin from "luamin";

const re = /require[ (]"([^"]+)"\)?;?\s?/g;

export class Library {
    public name: string;
    public path: string;
    public requires: string[] = [];
    public content: string = "";
    public loader: Loader;

    constructor(name: string, path: string, loader: Loader) {
        this.name = name;
        this.path = path;
        this.loader = loader;
    }

    public build(): string {
        // Iterate over every library in this library's requires.
        const requireStack: string[] = [ ...this.requires ];
        const requires: string[] = [ ...this.requires ];
        while (requireStack.length > 0) {
            const require = requireStack.pop();
            const lib = this.loader.get(require as string);
            for (const r of lib.requires) {
                if (!requires.includes(r)) {
                    requireStack.push(r);
                    requires.push(r);
                }
            }
        }

        let result = "";
        for (const data of requires.map((r) => this.loader.get(r)).reverse()) {
            result += data.content;
        }
        result += this.content;

        return luamin.minify(result);
    }
}

export default class Loader {
    public root: string;
    public libraries: { [name: string]: Library } = {};

    constructor(root: string) {
        this.root = root;
    }

    public get(name: string): Library {
        return this.libraries[name];
    }

    public parse(p: string): Library {
        // If p ends with .lua, remove it.
        if (p.endsWith(".lua")) {
            p = p.substring(0, p.length - 4);
        }

        // console.log(path.join(this.root, p.replace(".", "/") + ".lua"));
        // console.log(">>", p.replace(".", "/"))
        let contents = fs.readFileSync(
            path.join(this.root, p.replaceAll(".", "/") + ".lua"),
            "utf8");
        const lib = new Library(p, p.split(".").pop() as string, this);
        for (const match of contents.matchAll(re) || []) {
            lib.requires.push(match[1])
            this.libraries[match[1]] = this.parse(match[1]);
            contents = contents.replace(match[0], "");
        }

        lib.content = contents;
        this.libraries[lib.name] = lib;

        return lib;
    }
}