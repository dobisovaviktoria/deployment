package be.kdg.infra.repository;

import be.kdg.infra.domain.GroceryItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroceryRepository extends JpaRepository<GroceryItem, Long> {
}
