package be.kdg.infra.controller;

import be.kdg.infra.domain.Category;
import be.kdg.infra.domain.GroceryItem;
import be.kdg.infra.service.GroceryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/groceries")
public class GroceryApiController {
    private final GroceryService groceryService;

    public GroceryApiController(GroceryService groceryService) {
        this.groceryService = groceryService;
    }

    @GetMapping
    public List<GroceryItem> getAllItems() {
        return groceryService.getAllItems();
    }

    @GetMapping("/categories")
    public Category[] getAllCategories() {
        return Category.values();
    }

    @PostMapping
    public GroceryItem addItem(@RequestBody GroceryItem item) {
        return groceryService.addItem(item);
    }

    @DeleteMapping("/{id}")
    public void deleteItem(@PathVariable Long id) {
        groceryService.deleteItem(id);
    }
}
