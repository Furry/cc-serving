import express from "express";
import Loader, { Library } from "./loader.js";
import fs from "fs";
import * as ngrok from "ngrok";
import { getFiles } from "./utils.js";
import path from "path";
import dotenv from "dotenv";

dotenv.config();
const server = express();
const loader = new Loader("./static");

server.get("/files/*", (req, res) => {
    const p = path.join(
        loader.root,
        req.url
    );

    if (fs.existsSync(p)) {
        res.send(fs.readFileSync(p, "utf8"))
    } else {
        res.sendStatus(404);
    }
})

server.get("/*", (req, res) => {
    if (req.url.includes("favicon")) return;
    if (req.url == "/ping") return res.send("pong");

    const url = path.normalize(req.url);

    if (!fs.existsSync(path.join("./static/", url))) {
        return res.send(`print("File '${url}' not found.")`)
    }

    res.send(
        loader.parse(url).build()
    );
})

server.listen(8080, () => {
    console.log("Connecting to ngrok..");
    ngrok.connect({
        protocol: "http",
        port: 8080,
        authtoken: process.env.NGROK_TOKEN,
        subdomain: "lua-served"
    }).then((url) => {
        console.log(`Tunnel created at ${url}`);
        for (const file of getFiles(loader.root)) {
            const parsedFile = path.parse(file);
            const name = file.substr(7);
            if (parsedFile.ext == ".lua" && !name.startsWith("libs")) {
                console.log("| ", path.parse(file).name);
                console.log(`\t^ loadstring(http.get("${url}/${file.substr(7)}").readAll())()`);
            }
        }
    })
})