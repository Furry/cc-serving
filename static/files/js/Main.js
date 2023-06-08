import { InventoryManager, IconManager } from "./InventoryManager.js";
 
document.inventory = new InventoryManager();
document.icons = new IconManager();

(async () => {

    // Construct the list of icons //
    const iconDict = await fetch(`${document.location.origin}/files/item_icons.json`)
        .then((response) => response.json());

    document.icons.iconSet = new Set(iconDict);

    // Get the initial list of items //
    const items = await fetch(`${document.location.origin}/invitems`)
        .then((response) => response.json());

    console.log(items)
    document.inventory.setItems(items);

    console.log(document.inventory)
})();