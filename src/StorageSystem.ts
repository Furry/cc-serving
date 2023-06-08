export interface Item {
    damage: number;
    name: string;
    mod: string;
}

export interface ItemStack {
    count: number;
    name: string;
    item: Item;
}

export class StorageSystem {
    private contents: ItemStack[] = [];

    public syncItems(itemList: ItemStack[]) {
        this.contents = itemList;
        console.log("Synced: ", this.contents);
    }

    public getItems() {
        return this.contents;
    }
}