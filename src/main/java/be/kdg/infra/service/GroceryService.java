package be.kdg.infra.service;

import be.kdg.infra.domain.GroceryItem;
import be.kdg.infra.repository.GroceryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GroceryService {

    private final GroceryRepository repository;

    public GroceryService(GroceryRepository repository) {
        this.repository = repository;
    }

    public List<GroceryItem> getAllItems() {
        return repository.findAll();
    }

    public GroceryItem addItem(GroceryItem item) {
        repository.save(item);
        return item;
    }

    public void deleteItem(Long id) {
        repository.deleteById(id);
    }
}
