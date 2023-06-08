import express from "express";
import fastify from "fastify";
import fastifyws from "@fastify/websocket";

import ws from "ws";

import Loader, { Library } from "./loader.js";
import fs from "fs";
import * as ngrok from "ngrok";
import { getFiles } from "./utils.js";
import path from "path";
import dotenv from "dotenv";
import handleSocket from "./socketManager.js";

dotenv.config();
const loader = new Loader("./static");
const server = fastify();

server.register(fastifyws);
server.register(async (server) => {
    handleSocket(server);

    server.post("/logs", (req, res) => {
        // If it's json, stringify it
        const body = (req.body as any).toString()
        try {
            const json = JSON.parse(body);
            console.log(json)
        } catch {
            console.log(body)
        }

        res.send("ok")
    })

    server.get("/ae2", (req, res) => {
        res.type("text/html").send(
            fs.readFileSync("./static/files/web.html").toString()
        )
    })

    server.get("/files/*", (req, res) => {
        const p = path.join(
            loader.root,
            req.url
        );
    
        // If it's a png, send it as a png.
        if (fs.existsSync(p)) {
            if (p.endsWith(".png")) {
                res.type("image/png").send(fs.readFileSync(p));
            } else if (p.endsWith(".js" || p.endsWith(".mjs"))) {
                res.type("application/javascript").send(fs.readFileSync(p, "utf8"));
            } else {
                res.send(fs.readFileSync(p, "utf8"))
            }
        } else {
            res.status(404);
        }
    })
    
    server.get("/*", (req, res) => {
        // @ts-ignore
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
})

server.listen({ port: 4545 }).then(async () => {
    console.log("Connecting to ngrok..");
    // await ngrok.upgradeConfig({ relocate: true });
    ngrok.connect({
        protocol: "http",
        port: 4545,
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