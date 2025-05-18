package be.kdg.infra.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
public class GroceryItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int quantity;
    @Enumerated(EnumType.STRING)
    private Category category;

    public GroceryItem(String name, int quantity, Category category) {
        this.name = name;
        this.quantity = quantity;
        this.category = category;
    }

    public GroceryItem() {
    }
}
