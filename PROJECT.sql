CREATE DATABASE project;
USE Project;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------T  A  B  L  E  S--------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                        
SELECT * FROM album;
SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;	
SELECT * FROM invoice_line;
SELECT * FROM media_type;
SELECT * FROM playlist;
SELECT * FROM playlist_track;
SELECT * FROM track;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------P  H  A  S  E  -  1---------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1. Who is the senior most employee based on job title?

		SELECT * FROM employee
        WHERE title = "Senior General Manager";
        
        -- OR
        
        SELECT * FROM employee
        WHERE reports_to IS NULL;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2. Which countries have the most Invoices?

		SELECT billing_country AS BILLING_COUNTRY, SUM(total) AS TOTAL, count(*) as INVOICES 
        FROM invoice
        GROUP BY billing_country
        ORDER BY Invoices desc
        LIMIT 1;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q3 What are top 3 values of total invoice? 
			
		SELECT DISTINCT(total) AS TOTAL 
        FROM invoice
        ORDER BY total DESC
        LIMIT 3;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has
--    the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

		SELECT a.city AS CITY, SUM(b.total) AS TOTAL
        FROM customer a JOIN invoice b
        ON a.customer_id = b.customer_id
        GROUP BY CITY
        ORDER BY TOTAL DESC
        LIMIT 1;
        
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the 
--     most money 

		SELECT a.customer_id AS CUSTOMER_ID, CONCAT(a.first_name, a.last_name) AS CUSTOMER_NAME, SUM(b.total) AS TOTAL
        FROM customer a JOIN invoice b
        ON a.customer_id = b.customer_id
        GROUP BY CUSTOMER_ID, CUSTOMER_NAME
        ORDER BY TOTAL desc
        LIMIT 1;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------P  H  A  S  E  -  2---------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 

		SELECT DISTINCT a.email AS EMAIL, CONCAT(a.first_name, a.last_name) AS CUSTOMER_NAME, e.name AS GENRE
        FROM customer a 
        JOIN invoice b on  b.customer_id = a.customer_id  
        JOIN invoice_line c on c.invoice_id = b.invoice_id 
        JOIN track d on d.track_id = c.track_id 
        JOIN genre e on e.genre_id = d.genre_id 
        WHERE e.name LIKE "Rock" and a.email LIKE "a%"
        ORDER BY EMAIL;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands .

		SELECT a.name AS ARTIST_NAME, COUNT(*) AS TOTAL_TRACK
        FROM artist a
        JOIN album b on a.artist_id = b.artist_id
        JOIN track c on b.album_id = c.album_id
        JOIN genre d on c.genre_id = d.genre_id
        WHERE d.name LIKE "Rock"
        GROUP BY ARTIST_NAME
        ORDER BY TOTAL_TRACK DESC
        LIMIT 10;
	
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length 
--     with the longest songs listed first

		SELECT name AS TRACK_NAME, milliseconds AS MILLISECONDS
        FROM track
        WHERE milliseconds>(select AVG(milliseconds) from track)
        ORDER BY MILLISECONDS DESC;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------P  H  A  S  E  -  3---------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
 
		SELECT CONCAT(a.first_name, a.last_name) AS CUTOMER_NAME, f.name AS ARTIST_NAME, SUM(c.unit_price * c.quantity) as TOTAL_SPENT
        FROM customer a
        JOIN invoice b on  b.customer_id = a.customer_id  
        JOIN invoice_line c on c.invoice_id = b.invoice_id 
        JOIN track d on d.track_id = c.track_id 
        JOIN album e on e.album_id = d.album_id
        JOIN artist f on f.artist_id = e.artist_id
        GROUP BY CUTOMER_NAME, ARTIST_NAME
        ORDER BY TOTAL_SPENT DESC;
        
		-- OR
        
		WITH CTE AS (
		SELECT d.artist_id AS artist_id, d.name AS artist_name, SUM(a.unit_price*a.quantity) AS amount
		FROM invoice_line a
		JOIN track b ON b.track_id = a.track_id
		JOIN album c ON c.album_id = b.album_id
		JOIN artist d ON d.artist_id = c.artist_id
		GROUP BY d.artist_id,d.name)

		SELECT f.first_name, f.last_name, ct.artist_name, SUM(g.unit_price*g.quantity) AS Total_spent
		FROM invoice e
		JOIN customer f ON f.customer_id = e.customer_id
		JOIN invoice_line g ON g.invoice_id = e.invoice_id
		JOIN track h ON h.track_id = g.track_id
		JOIN album i ON i.album_id = h.album_id
		JOIN CTE ct ON ct.artist_id = i.artist_id
		GROUP BY f.first_name, f.last_name, ct.artist_name
		ORDER BY Total_spent DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
-- Q2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query
--     that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

		WITH CTE AS(
        SELECT a.country AS COUNTRY, e.name as TOP_GENRE, SUM(c.unit_price * c.quantity) as AMOUNT
        FROM customer a 
        JOIN invoice b on b.customer_id = a. customer_id
        JOIN invoice_line c on c.invoice_id = b.invoice_id
        JOIN track d on d.track_id = c.track_id
        JOIN genre e on e.genre_id = d.genre_id
        GROUP BY COUNTRY, TOP_GENRE),
        
		CTE1 AS(
        SELECT COUNTRY, TOP_GENRE,  DENSE_RANK () OVER (PARTITION BY country ORDER BY Amount DESC) as rnk
        FROM CTE
        GROUP BY COUNTRY, TOP_GENRE)
        
        SELECT COUNTRY, TOP_GENRE
        FROM CTE1
        WHERE rnk=1;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
-- Q3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and 
--     how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

		WITH CTE AS(
        SELECT a.country as COUNTRY, CONCAT(a.first_name," " ,a.last_name) as TOP_CUSTOMERS, SUM(c.unit_price * c.quantity) as AMOUNT
		FROM customer a 
        JOIN invoice b on b.customer_id = a. customer_id
        JOIN invoice_line c on c.invoice_id = b.invoice_id
        GROUP BY COUNTRY, TOP_CUSTOMERS),
		
        CTE1 AS(                                                                                                      
        SELECT COUNTRY, TOP_CUSTOMERS, AMOUNT, DENSE_RANK () OVER (PARTITION BY COUNTRY ORDER BY AMOUNT DESC) as rnk
		FROM CTE)                                                                                                   
                 
        SELECT COUNTRY, TOP_CUSTOMERS, AMOUNT
        FROM CTE1
        WHERE rnk = 1;
        
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------O		V		E		R--------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 