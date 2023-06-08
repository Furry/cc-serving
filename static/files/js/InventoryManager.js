export class IconManager {
    constructor() {
        this.iconSet = new Set()
    }
}

export class InventoryManager {
    constructor() {
        this.contents = [];
    }

    setItems(items) {
        this.contents = items;
    }
}