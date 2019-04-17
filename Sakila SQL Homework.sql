USE sakila;

-- MySQL script written by Radha Mahalingam 4-14-19

-- 1a) Display the first and last names of all actors from the table `actor`

SELECT first_name, last_name FROM actor;

-- 1b) Display the first and last name of each actor in a single column 
--     in upper case letters. Name the column `Actor Name`

SELECT upper(CONCAT(first_name, ' ', last_name)) AS 'Actor Name' FROM actor;

-- 2a) You need to find the ID number, first name, and last name of an actor, 
--     of whom you know only the first name, "Joe." What is one query would you use to 
--     obtain this information?

SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

-- 2b) Find all actors whose last name contain the letters `GEN`

SELECT actor_id, first_name, last_name FROM actor WHERE last_name like '%GEN%';

-- 2c) Find all actors whose last names contain the letters `LI`. 
--     This time, order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name FROM actor WHERE last_name like '%LI%' ORDER BY last_name, first_name;

-- 2d) Using `IN`, display the `country_id` and `country` columns of the following countries: 
--     Afghanistan, Bangladesh, and China

SELECT country_id, country FROM country WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries 
--     on a description, so create a column in the table `actor` named `description` and use the data type 
--     `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER table actor ADD (description blob default Null);
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much 
--     effort. Delete the `description` column.

 ALTER table actor DROP column description;
 SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
--     but only for names that are shared by at least two actors

SELECT last_name, count(last_name) FROM actor GROUP BY last_name HAVING count(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
--     Write a query to fix the record.

UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT first_name, last_name FROM actor WHERE first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was 
--    the correct name after all! In a single query, 
--    if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

SELECT first_name, last_name FROM actor WHERE first_name = 'HARPO';
COMMIT;
UPDATE actor set first_name = 'GROUCHO' WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';
SELECT first_name, last_name FROM actor WHERE first_name = 'GROUCHO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

CREATE TABLE `address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) NOT NULL,
 `address2` varchar(50) DEFAULT NULL,
 `district` varchar(20) NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`),
 KEY `idx_fk_city_id` (`city_id`),
 SPATIAL KEY `idx_location` (`location`),
 CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
--     Use the tables `staff` and `address`:

SELECT a.first_name, a.last_name, b.address FROM staff AS a
LEFT JOIN address AS b ON b.address_id = a.address_id;

--  6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
--      Use tables `staff` and `payment`.

SELECT * FROM payment WHERE month(payment_date)= 8 AND year(payment_date) = 2005;
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Revenue by Staff' FROM staff 
INNER JOIN payment ON staff.staff_id = payment.staff_id 
WHERE MONTH(payment.payment_date) = 8 AND YEAR(payment.payment_date) = 2005
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
--     Use tables `film_actor` and `film`. Use inner join.

SELECT film.title, COUNT(film_actor.actor_id) AS 'Number of actors' FROM film 
INNER JOIN film_actor ON film.film_id = film_actor.film_id 
GROUP BY film_actor.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT film.film_id, film.title, COUNT(inventory.inventory_id) AS 'Number of copies in the system'  FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
WHERE film.title = "Hunchback Impossible"
GROUP BY inventory.film_id;

-- Testing
-- SELECT film_id, inventory_id FROM inventory WHERE film_id = 439;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total 
--     paid by each customer. List the customers alphabetically by last name:

SELECT 
   customer.first_name,
   customer.last_name,
   SUM(payment.amount) AS 'Total paid by each customer'
FROM
   customer
LEFT JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
--     As an unintended consequence, films starting with the letters `K` and `Q` have 
--     also soared in popularity. Use subqueries to display the titles of movies 
--     starting with the letters `K` and `Q` whose language is English.

SELECT title FROM film WHERE language_id IN 
      (SELECT language_id FROM language WHERE name = "English" ) AND (title LIKE "K%") OR (title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name FROM actor WHERE actor_id IN 
      (SELECT actor_id FROM film_actor WHERE film_id IN
         (SELECT film_id from film WHERE title = "Alone Trip" )); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will 
--     need the names and email addresses of all Canadian customers. Use joins to 
--     retrieve this information.

SELECT customer.last_name, customer.first_name, customer.email FROM customer 
INNER JOIN customer_list ON customer.customer_id = customer_list.ID 
WHERE customer_list.country = 'Canada';

--  7d. Sales have been lagging among young families, and you wish to 
--      target all family movies for a promotion. Identify all movies 
--      categorized as _family_ films.

SELECT * FROM category
SELECT title FROM film WHERE film_id IN 
   (SELECT film_id FROM film_category WHERE category_id IN 
         (SELECT category_id FROM category WHERE name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
-- SELECT * FROM rental; 
-- SELECT * FROM inventory;
-- SELECT * FROM film;

 SELECT film.title, COUNT(*) AS 'rent count' FROM film, inventory, rental 
 WHERE film.film_id = inventory.film_id AND rental.inventory_id = inventory.inventory_id 
 GROUP BY inventory.film_id 
 ORDER BY COUNT(*) DESC, film.title ASC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

-- SELECT * FROM store; 
-- SELECT * FROM payment;
-- SELECT * FROM staff;

SELECT store.store_id, SUM(amount) AS store_revenue FROM store 
INNER JOIN staff ON store.store_id = staff.store_id 
INNER JOIN payment ON payment.staff_id = staff.staff_id GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

-- SELECT * FROM store; 
-- SELECT * FROM city;
-- SELECT * FROM country;
-- SELECT * FROM address;

SELECT store.store_id, city.city, country.country FROM store 
INNER JOIN address ON store.address_id = address.address_id 
INNER JOIN city ON address.city_id = city.city_id 
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
--     (**Hint**: you may need to use the following tables: category, film_category, 
--     inventory, payment, and rental.)

-- SELECT * FROM film_category; 
-- SELECT * FROM film_category;
-- SELECT * FROM inventory;
-- SELECT * FROM rental;

SELECT name, SUM(pmt.amount) AS gross_revenue FROM category cat 
INNER JOIN film_category fcat ON fcat.category_id = cat.category_id 
INNER JOIN inventory inv ON inv.film_id = fcat.film_id 
INNER JOIN rental ren ON ren.inventory_id = inv.inventory_id 
RIGHT JOIN payment pmt ON pmt.rental_id = ren.rental_id 
GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
--     the Top five genres by gross revenue. Use the solution from the problem above to 
--     create a view. If you haven't solved 7h, you can substitute another query to create 
--     a view.

DROP VIEW IF EXISTS top_five_genres; 

CREATE VIEW top_five_genres AS
   SELECT name, SUM(pmt.amount) AS gross_revenue FROM category cat 
     INNER JOIN film_category fcat ON fcat.category_id = cat.category_id 
     INNER JOIN inventory inv ON inv.film_id = fcat.film_id 
     INNER JOIN rental ren ON ren.inventory_id = inv.inventory_id 
     RIGHT JOIN payment pmt ON pmt.rental_id = ren.rental_id 
     GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to 
--     delete it.

DROP VIEW top_five_genres;














