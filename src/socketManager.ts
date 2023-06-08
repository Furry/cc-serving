import Router from "express";
import express from "express";
import WebSocket from "ws";
import Fastify, { FastifyInstance } from "fastify";

import { Item, ItemStack, StorageSystem } from "./StorageSystem";

interface GenericObject {
    [key: string]: any;
}

interface InventoryUpdate {
    type: "update";
    items: {
        action: "add" | "remove";
        count: number;
        item: Item;
    }
}

interface Init {
    type: "init";
    items: ItemStack[];
}

interface Identify {
    type: "identify";
}

type Response = InventoryUpdate | Init | Identify;

const storageSystem = new StorageSystem();

export default function handleSocket(server: FastifyInstance) {
    let ccServer: any = null;

    server.get('/invitems', (req, res) => {
        res.send(storageSystem.getItems());
    })

    server.get('/socket', { websocket: true }, (connection: { socket: { on: (arg0: string, arg1: (message: any) => void) => void; send: (arg0: string) => void; }; } /* SocketStream */, req: any /* FastifyRequest */) => {
        connection.socket.on('message', (message) => {
        const data = JSON.parse(message.toString()) as Response;
            switch (data.type) {
                case "identify": {
                    ccServer = connection.socket;
                }; break;

                case "init": {
                    console.log(data)
                    storageSystem.syncItems(data.items)
                }
                default: {
                }; break;
            }
        })
    })
}