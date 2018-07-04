USE sakila;

-- 1a first and last names of actors from actor
SELECT first_name, last_name FROM actor;

-- 1b first and last name of actor in single column uppercase
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS "Actor Name" FROM actor;

-- 2a ID, first name, last name of actor of Joe
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- 2b All actors last names contains "GEN"
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c All actors lastname LI order by lastname and firstname
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d Using IN, display country_id and country of Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a add middle name column between first and last name
 ALTER TABLE actor 
 ADD COLUMN middle_name VARCHAR(45) NULL AFTER first_name;
 
 -- 3b long names to blobs
ALTER TABLE actor 
CHANGE COLUMN middle_name middle_name BLOB NULL DEFAULT NULL;

-- 3c delete middle name
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a List the last names of actors, as well as how many actors have that last name. 
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' FROM actor 
GROUP BY last_name;

-- 4b List last names of actors and number of actors with same last name, names that are shared by two actors
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' FROM actor 
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c Groucho Williams to Harpo Williams fix
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
UPDATE actor SET first_name = 'HARPO' WHERE actor_id = 172;

-- 4d Harpo to Groucho else mucho groucho
UPDATE actor SET first_name = 
CASE WHEN first_name = 'HARPO' 
THEN 'GROUCHO' 
ELSE 'MUCHO GROUCHO' 
END 
WHERE actor_id = 172;

-- 5a create address table again
SHOW CREATE TABLE address; 
CREATE TABLE IF NOT EXISTS address ( 
address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT, 
address varchar(50) NOT NULL, 
address2 varchar(50) DEFAULT NULL, 
district varchar(20) NOT NULL, 
city_id smallint(5) unsigned NOT NULL, 
postal_code varchar(10) DEFAULT NULL, 
phone varchar(20) NOT NULL, 
location geometry NOT NULL, 
last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
PRIMARY KEY (address_id), 
KEY idx_fk_city_id (city_id), 
SPATIAL KEY idx_location (location), 
CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a JOIN staff and address
SELECT staff.first_name, staff.last_name, address.address FROM address
JOIN staff ON staff.address_id = address.address_id;


-- 6b JOIN staff and payment
SELECT payment.staff_id, SUM(amount) FROM payment
JOIN staff ON staff.staff_id = payment.staff_id
WHERE payment_date BETWEEN "2005-07-31" AND "2005-09-01"
GROUP BY staff_id;

-- 6c film and num of actors - film and film_actors
SELECT title, COUNT(*) FROM film 
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d num of hunchback impossible
SELECT COUNT(*) FROM inventory
JOIN film ON inventory.film_id = film.film_id
WHERE title = "Hunchback Impossible";


-- 6e JOIN payment and customer, total paid per customer alphabetically by last name
SELECT last_name, SUM(amount) FROM customer
JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY last_name
ORDER BY last_name ASC;

-- 7a Movies starting with K and Q in English
SELECT title FROM film
WHERE language_id IN 
(SELECT language_id FROM language WHERE name = "English")
AND title LIKE "K%"
OR title LIKE "Q%";

-- 7b subqueries actors in alone trip
SELECT first_name, last_name FROM actor
WHERE actor_id IN 
(SELECT actor_id FROM film_actor
JOIN film ON film.film_id = film_actor.film_id
WHERE title = "Alone Trip");

-- 7c Canadian emails and names
SELECT customer.first_name, customer.last_name, customer.email FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON country.country_id = city.country_id;


-- 7d Category family
SELECT title FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE name = "Family";

-- 7e most rented movies
SELECT Title, COUNT(*) as rental_count FROM film 
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(*) desc;

-- 7f dollar by store
SELECT store.store_id, sum(amount) FROM store
JOIN staff ON store.store_id = staff.store_id
JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY store.store_id;

-- 7g store id, city, country
SELECT store.store_id, city.city, country.country FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id;

-- 7h. Top five genres in gross revenue in descending order. 
-- (use: category, film_category, inventory, payment, and rental.)
-- 8a Save 7h as a view
DROP VIEW IF EXISTS top_five_genres; CREATE VIEW top_five_genres AS (
SELECT category.name, SUM(payment.amount) FROM film_category
JOIN category ON category.category_id = film_category.category_id
JOIN inventory ON inventory.film_id = category.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY desc);

-- 8b display view created in 8a
SELECT * FROM top_genres

-- 8c delete view created
DROP VIEW top_genres 




