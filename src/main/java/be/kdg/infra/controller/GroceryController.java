package be.kdg.infra.controller;

import be.kdg.infra.domain.Category;
import be.kdg.infra.domain.GroceryItem;
import be.kdg.infra.service.GroceryService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/groceries")
public class GroceryController {

    private final GroceryService groceryService;

    public GroceryController(GroceryService groceryService) {
        this.groceryService = groceryService;
    }

    @GetMapping
    public String index(Model model) {
        model.addAttribute("items", groceryService.getAllItems());
        model.addAttribute("newItem", new GroceryItem());
        model.addAttribute("categories", Category.values());
        return "index";
    }
}
