select * from actor where first_name = 'Scarlett';
select * from actor where last_name like 'Johansson';
select count(distinct last_name) from actor;
select last_name from actor group by last_name having count(*) = 1;
select last_name from actor group by last_name having count(*) > 1;
select actor.actor_id, actor.first_name, actor.last_name, count(actor_id) as film_count from actor join film_actor using (actor_id) group by actor_id order by film_count desc limit 1;
select film.film_id, film.title, store.store_id, inventory.inventory_id from inventory join store using (store_id) join film using (film_id) where film.title = 'Academy Dinosaur' and store.store_id = 1;
select inventory.inventory_id from inventory join store using (store_id) join film using (film_id) join rental using (inventory_id) where film.title = 'Academy Dinosaur' and store.store_id = 1 and not exists (select * from rental  where rental.inventory_id = inventory.inventory_id  and rental.return_date is null);
insert ignore into rental (rental_date, inventory_id, customer_id, staff_id) select now(), i.inventory_id, c.customer_id, s.staff_id from inventory i, customer c, staff s limit 10;
select rental_duration from film where film_id = 1;
select rental_id from rental order by rental_id desc limit 1;
select rental_date, rental_date + interval  (select rental_duration from film where film_id = 1) day  as due_date from rental where rental_id = (select rental_id from rental order by rental_id desc limit 1);
select avg(length) from film;
select category.name, avg(length) from film join film_category using (film_id) join category using (category_id) group by category.name order by avg(length) desc;
select category.name, avg(length) from film join film_category using (film_id) join category using (category_id) group by category.name having avg(length) > (select avg(length) from film) order by avg(length) desc;
SELECT first_name,last_name FROM actor;
SELECT UPPER(CONCAT(first_name,' ',last_name)) AS 'Actor Name' FROM actor;
SELECT actor_id, first_name, last_name FROM actor WHERE first_name='Joe';
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;
SELECT country_id, country FROM country WHERE country IN('Afghanistan', 'Bangladesh', 'China');
SELECT last_name, COUNT(*) as 'Last Name Count' FROM actor GROUP BY last_name;
SELECT last_name, COUNT(*) as 'Last Name Count' FROM actor GROUP BY last_name HAVING COUNT(*) >=2;
UPDATE actor SET first_name = 'HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name='HARPO' AND last_name='WILLIAMS';
SELECT first_name, last_name, address FROM staff INNER JOIN address ON staff.address_id = address.address_id;
SELECT first_name, last_name, SUM(amount) as 'Total Amount' FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%' GROUP BY first_name, last_name;
SELECT title, COUNT(actor_id) as 'Actor Count' FROM film_actor INNER JOIN film ON film_actor.film_id = film.film_id GROUP BY title;
SELECT title, COUNT(title) as 'Copies Available' FROM film INNER JOIN inventory ON film.film_id = inventory.film_id WHERE title = 'Hunchback Impossible';
SELECT first_name, last_name, SUM(amount) as 'Total Paid by Each Customer' FROM payment INNER JOIN customer ON payment.customer_id = customer.customer_id GROUP BY first_name, last_name ORDER BY last_name;
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND title IN ( SELECT title FROM film WHERE language_id IN ( SELECT language_id FROM language WHERE name ='English' ));
SELECT first_name, last_name FROM actor WHERE actor_id IN ( SELECT actor_id FROM film_actor WHERE film_id IN ( SELECT film_id FROM film WHERE title = 'Alone Trip' ) );
 SELECT first_name, last_name, email FROM customer JOIN address ON (customer.address_id = address.address_id) JOIN city ON (city.city_id = address.city_id) JOIN country ON (country.country_id = city.country_id) WHERE country.country= 'Canada';
SELECT title FROM film WHERE film_id IN ( SELECT film_id FROM film_category WHERE category_id IN ( SELECT category_id FROM category WHERE name='Family' ) );
SELECT title, COUNT(rental_id) as 'Rental Count' FROM rental JOIN inventory ON (rental.inventory_id = inventory.inventory_id) JOIN film ON (inventory.film_id = film.film_id) GROUP BY film.title ORDER BY COUNT(rental_id) DESC;
SELECT store.store_id, SUM(amount) FROM store INNER JOIN staff ON store.store_id = staff.store_id INNER JOIN payment ON payment.staff_id = staff.staff_id GROUP BY store.store_id;
SELECT store_id, city, country FROM store INNER JOIN address ON store.address_id = address.address_id INNER JOIN city ON city.city_id = address.city_id INNER JOIN country ON country.country_id = city.country_id;
SELECT name, SUM(amount) FROM category INNER JOIN film_category ON category.category_id = film_category.category_id INNER JOIN inventory ON film_category.film_id = inventory.film_id INNER JOIN rental ON inventory.inventory_id = rental.inventory_id INNER JOIN payment ON rental.rental_id = payment.rental_id GROUP BY name ORDER BY SUM(amount) DESC LIMIT 5;

