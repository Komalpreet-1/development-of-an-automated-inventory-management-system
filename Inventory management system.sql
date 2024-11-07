-- Create the database
CREATE DATABASE inventory_system;

-- Switch to the newly created database
USE inventory_system;

-- Create the products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
-- Create a stored procedure to add a new product to the inventory
DELIMITER $$

CREATE PROCEDURE AddProduct(
    IN p_product_name VARCHAR(100),
    IN p_quantity INT,
    IN p_price DECIMAL(10, 2)
)
BEGIN
    INSERT INTO products (product_name, quantity, price)
    VALUES (p_product_name, p_quantity, p_price);
    
    SELECT 'Product Added Successfully' AS result;
END $$

DELIMITER ;
-- Create a log table to track changes in stock
CREATE TABLE stock_changes (
    change_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    old_quantity INT,
    new_quantity INT,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Create a trigger to log stock changes when a product's quantity is updated
DELIMITER $$

CREATE TRIGGER after_stock_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Only log if the quantity has changed
    IF OLD.quantity != NEW.quantity THEN
        INSERT INTO stock_changes (product_id, old_quantity, new_quantity)
        VALUES (NEW.product_id, OLD.quantity, NEW.quantity);
    END IF;
END $$

DELIMITER ;
-- Call the stored procedure to add a new product
CALL AddProduct('Laptop', 50, 799.99);
CALL AddProduct('Smartphone', 200, 499.99);
-- Update the quantity of an existing product
UPDATE products SET quantity = 45 WHERE product_id = 1;

-- Check the stock change log
SELECT * FROM stock_changes;

