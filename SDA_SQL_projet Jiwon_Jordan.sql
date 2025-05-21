-- Projet SQL - SORBONNE DATA ANALYTICS - Jiwon, Jordan

-- ======================
-- PARTIE 1: Base de données Sakila
-- ======================

-- Question 1: Trouvez tous les films dont le titre contient les lettres "ace".
SELECT *
FROM film
WHERE title LIKE '%ace%';

-- Question 2: Affichez les films de plus de 120 minutes, triés par durée décroissante.
SELECT *
FROM film
WHERE length > 120
ORDER BY length DESC;

-- Question 3: Listez les titres de films de langue anglaise dont la dernière mise à jour (last_update) est postérieure à 2006.
SELECT f.title
FROM film f
JOIN language l ON f.language_id = l.language_id
WHERE l.name = 'English'
AND YEAR(f.last_update) > 2006;

-- Question 4: Affichez, pour chaque film, son titre, sa catégorie (nom) et la langue utilisée.
SELECT f.title, c.name AS categorie, l.name AS langue
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN language l ON f.language_id = l.language_id;

-- Question 5: Indiquez les 10 films les plus loués, avec leur titre et le nombre total de locations.
SELECT f.title, COUNT(r.rental_id) AS nombre_locations
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY nombre_locations DESC
LIMIT 10;

-- Question 6: Calculez le revenu total généré par chaque film (titre + somme des paiements).
SELECT f.title, SUM(p.amount) AS revenu_total
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
ORDER BY revenu_total DESC;

-- Question 7: Listez les films dont la durée est supérieure à la durée moyenne de tous les films.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- Question 8: Affichez les titres des films appartenant aux catégories "Action", "Comedy" ou "Drama", loués plus de 50 fois.
SELECT f.title, c.name AS categorie, COUNT(r.rental_id) AS nombre_locations
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Action', 'Comedy', 'Drama')
GROUP BY f.film_id, f.title, c.name
HAVING COUNT(r.rental_id) > 50
ORDER BY nombre_locations DESC;

-- Question 9: Affichez les 5 clients les plus rentables, avec leur nom, e-mail, ville et montant total payé.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS nom_client, 
    c.email, 
    ci.city AS ville, 
    SUM(p.amount) AS montant_total
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, ci.city
ORDER BY montant_total DESC
LIMIT 5;

-- Question 10: Listez les clients ayant encore un DVD en circulation (non retourné), avec leur nom, numéro de téléphone, e-mail et titre du film.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS nom_client, 
    a.phone AS telephone, 
    c.email, 
    f.title AS titre_film
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date IS NULL;

-- Question 11: Affichez les ventes mensuelles (montant total encaissé) par magasin pour l'année 2005. Formatez les mois en AAAAMM.
SELECT 
    i.store_id AS magasin,
    DATE_FORMAT(p.payment_date, '%Y%m') AS mois,
    SUM(p.amount) AS ventes_totales
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE YEAR(p.payment_date) = 2005
GROUP BY i.store_id, DATE_FORMAT(p.payment_date, '%Y%m')
ORDER BY i.store_id, mois;

-- Question 12: Affichez le montant total encaissé par chaque employé (staff) au mois de juin 2005.
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS nom_employe,
    SUM(p.amount) AS montant_total
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
WHERE YEAR(p.payment_date) = 2005 AND MONTH(p.payment_date) = 6
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY montant_total DESC;

-- Question 13: Créez une vue top_films_2005 listant les 20 films ayant généré le plus de revenus en 2005.
DROP VIEW IF EXISTS top_films_2005;
CREATE VIEW top_films_2005 AS
SELECT 
    f.film_id,
    f.title AS titre,
    SUM(p.amount) AS revenu_total
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE YEAR(p.payment_date) = 2005
GROUP BY f.film_id, f.title
ORDER BY revenu_total DESC
LIMIT 20;

-- Question 14: Créez une vue vip_clients regroupant les clients ayant payé plus de 200 dollars.
DROP VIEW IF EXISTS vip_clients;
CREATE VIEW vip_clients AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS nom_client,
    c.email,
    SUM(p.amount) AS montant_total
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING SUM(p.amount) > 200
ORDER BY montant_total DESC;

-- Question 15: Insérez un acteur fictif avec la commande INSERT, puis supprimez-le avec DELETE, en respectant les contraintes d'intégrité.
INSERT INTO actor (first_name, last_name)
VALUES ('Jean', 'Dupont');

SET @acteur_id = LAST_INSERT_ID();

DELETE FROM actor 
WHERE actor_id = @acteur_id;

-- Question 16: Trouvez le titre du film, le nom du client, le numéro de téléphone du client et l'adresse du client pour tous les DVD en circulation (qui n'ont pas prévu d'être rendus)
SELECT 
    f.title AS titre_film,
    CONCAT(c.first_name, ' ', c.last_name) AS nom_client,
    a.phone AS telephone,
    CONCAT(a.address, ', ', ci.city, ', ', co.country) AS adresse_complete
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE r.return_date IS NULL;

-- ======================
-- PARTIE 2: Test technique (type entreprise)
-- ======================

-- Question 1: Comment optimiser les requêtes SQL?
/*
1. Utiliser des index appropriés sur les colonnes fréquemment utilisées dans les clauses WHERE, JOIN, ORDER BY
2. Éviter d'utiliser SELECT * et sélectionner uniquement les colonnes nécessaires
3. Utiliser des jointures efficaces et limiter leur nombre
4. Utiliser des sous-requêtes et des vues matérialisées quand c'est pertinent
5. Analyser et optimiser les plans d'exécution avec EXPLAIN
6. Partitionner les grandes tables si nécessaire
7. Utiliser des requêtes préparées pour les opérations répétitives
8. Maintenir les statistiques de la base de données à jour
9. Éviter les fonctions dans les clauses WHERE qui empêchent l'utilisation des index
10. Utiliser LIMIT pour limiter les résultats si tous ne sont pas nécessaires
*/

-- Question 2: Comment supprimer les lignes en double d'une table?
/*
Méthode 1: Utiliser une clé primaire ou un index unique
*/
ALTER TABLE employes ADD PRIMARY KEY (id);

/*
Méthode 2: Utiliser une table temporaire
*/
CREATE TEMPORARY TABLE temp_employes AS
SELECT DISTINCT * FROM employes;

TRUNCATE TABLE employes;

INSERT INTO employes
SELECT * FROM temp_employes;

DROP TEMPORARY TABLE temp_employes;

/*
Méthode 3: Utiliser DELETE avec self-join
*/
DELETE e1 FROM employes e1
INNER JOIN employes e2 
WHERE e1.id > e2.id 
AND e1.nom = e2.nom 
AND e1.email = e2.email;

/*
Méthode 4: Avec ROW_NUMBER() (pour MySQL 8.0+)
*/
WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY nom, email
            ORDER BY id
        ) AS row_num
    FROM employes
)
DELETE FROM CTE WHERE row_num > 1;

-- Question 3: Quelles sont les principales différences entre les clauses HAVING et WHERE en SQL?
/*
1. La clause WHERE filtre les lignes avant qu'elles soient regroupées (GROUP BY)
2. La clause HAVING filtre les groupes après l'opération de regroupement
3. WHERE s'applique aux lignes individuelles, HAVING s'applique aux groupes
4. WHERE ne peut pas contenir de fonctions d'agrégation (SUM, COUNT), HAVING le peut
5. WHERE est exécuté avant GROUP BY, HAVING est exécuté après

Exemple:
*/
-- Utilisation de WHERE (filtre avant regroupement)
SELECT department_id, AVG(salary)
FROM employes
WHERE salary > 5000
GROUP BY department_id;

-- Utilisation de HAVING (filtre après regroupement)
SELECT department_id, AVG(salary)
FROM employes
GROUP BY department_id
HAVING AVG(salary) > 5000;

-- Question 4: Quelle est la différence entre normalisation et dénormalisation?
/*
Normalisation:
1. Processus de structuration d'une base de données pour réduire la redondance
2. Divise les grandes tables en plus petites et les relie par des relations
3. Améliore l'intégrité des données et réduit les anomalies de mise à jour
4. Généralement organisée en formes normales (1NF, 2NF, 3NF, BCNF, etc.)
5. Optimise l'espace de stockage

Dénormalisation:
1. Processus inverse qui combine des tables normalisées
2. Introduit intentionnellement de la redondance pour améliorer les performances de lecture
3. Réduit le nombre de jointures nécessaires pour les requêtes complexes
4. Utilisée dans les entrepôts de données et systèmes analytiques
5. Peut compliquer les mises à jour et insertions de données
*/

-- Question 5: Quelles sont les principales différences entre les commandes DELETE et TRUNCATE en SQL?
/*
DELETE:
1. Supprime des lignes spécifiques ou toutes les lignes (avec possibilité de filtrage avec WHERE)
2. Transaction qui peut être annulée (ROLLBACK)
3. Déclenche les triggers
4. Conserve l'espace alloué à la table et ne réinitialise pas les compteurs d'auto-incrémentation
5. Plus lent que TRUNCATE pour de grandes quantités de données
6. Journalise chaque suppression de ligne

TRUNCATE:
1. Supprime toutes les lignes de la table (pas de clause WHERE)
2. DDL qui ne peut généralement pas être annulée
3. Ne déclenche pas les triggers
4. Libère l'espace disque et réinitialise les compteurs d'auto-incrémentation
5. Plus rapide que DELETE pour de grandes tables
6. Journalise uniquement la libération des pages de données
*/

-- Question 6: Quelles sont les façons d'empêcher les entrées en double lors d'une requête?
/*
1. Utiliser des contraintes d'unicité (UNIQUE) sur les colonnes ou combinaisons de colonnes
2. Créer des index uniques
3. Utiliser la clause ON DUPLICATE KEY UPDATE pour MySQL
4. Implémenter des contraintes de clé primaire
5. Utiliser INSERT IGNORE pour ignorer silencieusement les duplications
6. Effectuer une vérification préalable avec EXISTS avant d'insérer
7. Utiliser MERGE ou UPSERT dans certains SGBD
8. Pour les insertions multiples, utiliser INSERT ... SELECT DISTINCT
*/

-- Exemple de contrainte UNIQUE
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    nom VARCHAR(100)
);

-- Exemple d'insertion avec gestion des doublons
INSERT INTO clients (email, nom)
VALUES ('client@exemple.com', 'Jean Dupont')
ON DUPLICATE KEY UPDATE 
    nom = VALUES(nom);

-- Question 7: Quels sont les différents types de relations en SQL?
/*
1. Relation Un-à-Un (1:1):
   - Chaque enregistrement d'une table est lié à au plus un enregistrement dans une autre table
   - Exemple: Une personne et son passeport

2. Relation Un-à-Plusieurs (1:N):
   - Un enregistrement d'une table peut être lié à plusieurs enregistrements dans une autre table
   - Exemple: Un département et ses employés

3. Relation Plusieurs-à-Plusieurs (N:M):
   - Plusieurs enregistrements d'une table peuvent être liés à plusieurs enregistrements dans une autre table
   - Nécessite une table de jonction
   - Exemple: Des étudiants et des cours

4. Relation Réflexive (Self-Referencing):
   - Une table qui a une relation avec elle-même
   - Exemple: Structure hiérarchique des employés (manager-subordonné)
*/

-- Question 8: Insérer les données dans les tables subject et student

-- Création de la table subject si elle n'existe pas
CREATE TABLE IF NOT EXISTS subject (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100),
    max_score INT,
    lecturer VARCHAR(100)
);

-- Création de la table student si elle n'existe pas
CREATE TABLE IF NOT EXISTS student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    city VARCHAR(100),
    subject_id INT,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id)
);

-- Insertion des données dans la table 'subject'
INSERT INTO subject (subject_id, subject_name, max_score, lecturer) VALUES
(11, 'Math', 130, 'Charlie Sole'),
(12, 'Computer Science', 50, 'James Pillet'),
(13, 'Biology', 300, 'Carol Denby'),
(14, 'Geography', 220, 'Yollanda Balang'),
(15, 'Physics', 110, 'Chris Brother'),
(16, 'Chemistry', 400, 'Manny Donne');

-- Insertion des données dans la table 'student'
INSERT INTO student (student_id, student_name, city, subject_id) VALUES
(2001, 'Olga Thorn', 'New York', 11),
(2002, 'Sharda Clement', 'San Francisco', 12),
(2003, 'Bruce Shelkins', 'New York', 13),
(2004, 'Fabian Johnson', 'Boston', 15),
(2005, 'Bradley Camer', 'Stanford', 11),
(2006, 'Sofia Mueller', 'Boston', 16),
(2007, 'Rory Pietman', 'New Haven', 12),
(2008, 'Carly Walsh', 'Tulsa', 14),
(2011, 'Richard Curtis', 'Boston', 11),
(2012, 'Cassey Ledgers', 'Stanford', 11),
(2013, 'Harold Ledgers', 'Miami', 13),
(2014, 'Davey Bergman', 'San Francisco', 12),
(2015, 'Darcey Button', 'Chicago', 14);

-- Requête pour afficher les cours, les noms des matières et le nombre d'étudiants pour les cours ayant au moins 3 étudiants
SELECT 
    s.subject_id AS id_cours, 
    s.subject_name AS nom_matiere, 
    COUNT(st.student_id) AS nombre_etudiants
FROM subject s
JOIN student st ON s.subject_id = st.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(st.student_id) >= 3;

-- Question 9: Requêtes sur la table Orders

-- Création de la table Orders si elle n'existe pas
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total DECIMAL(10,2)
);

-- Insertion des données d'exemple dans la table Orders
INSERT INTO Orders (order_id, customer_id, order_date, total) VALUES
(1, 100, '2021-01-01', 200),
(2, 101, '2021-02-02', 300),
(3, 102, '2021-03-03', 400),
(4, 103, '2021-04-04', 500),
(5, 104, '2021-05-05', 600);

-- Création de la table Order_items si elle n'existe pas
CREATE TABLE IF NOT EXISTS Order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Insertion des données d'exemple dans la table Order_items
INSERT INTO Order_items (order_id, product_id, quantity, price) VALUES
(1, 10, 2, 50),
(1, 11, 3, 25),
(2, 12, 4, 30),
(2, 13, 5, 20),
(3, 14, 6, 15),
(3, 15, 7, 10),
(4, 16, 8, 5),
(4, 17, 9, 4),
(5, 18, 10, 3),
(5, 19, 11, 2);

-- Récupérer les commandes avec un total supérieur à 400
SELECT order_id, customer_id, total
FROM Orders
WHERE total > 400;

-- Récupérer le montant total dépensé par chaque client, trié par montant total décroissant
SELECT customer_id, SUM(total) AS total_amount_spent
FROM Orders
GROUP BY customer_id
ORDER BY total_amount_spent DESC;

-- Question 10: Requête montrant la quantité totale vendue pour chaque produit

-- Création de la table order_items pour la question 10 si elle n'existe pas
CREATE TABLE IF NOT EXISTS order_items_q10 (
    order_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- Insertion des données d'exemple dans la table order_items_q10
INSERT INTO order_items_q10 (order_id, order_date, customer_id, product_id, quantity) VALUES
(1, '2022-01-01', 101, 1, 2),
(2, '2022-01-01', 102, 1, 1),
(3, '2022-01-01', 103, 2, 5),
(4, '2022-01-02', 104, 3, 3),
(5, '2022-01-02', 105, 1, 2),
(6, '2022-01-02', 101, 3, 1),
(7, '2022-01-03', 102, 2, 4),
(8, '2022-01-03', 103, 1, 2),
(9, '2022-01-03', 104, 2, 1),
(10, '2022-01-04', 105, 3, 2);

-- Requête pour afficher la quantité totale vendue pour chaque produit
SELECT 
    product_id,
    SUM(quantity) AS total_quantity_sold
FROM order_items_q10
GROUP BY product_id
ORDER BY product_id;

-- Question 11: Insertion des données de commandes clients dans trois tables

-- Création des tables nécessaires pour la question 11
CREATE TABLE IF NOT EXISTS Customers (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Orders_q11 (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(id)
);

CREATE TABLE IF NOT EXISTS OrderDetails (
    id INT PRIMARY KEY,
    order_id INT,
    product VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders_q11(id)
);

-- Table temporaire simulant les données source
CREATE TEMPORARY TABLE IF NOT EXISTS customer_orders (
    customer_id INT,
    customer_name VARCHAR(100),
    customer_address VARCHAR(255),
    customer_city VARCHAR(100),
    customer_country VARCHAR(100),
    order_id INT,
    order_date DATE,
    order_total DECIMAL(10,2),
    product_name VARCHAR(100),
    order_quantity INT
);

-- Insertion de quelques données d'exemple
INSERT INTO customer_orders VALUES
(1, 'John Smith', '123 Main St.', 'Anytown', 'USA', 1, '2022-01-01', 100, 'Widget A', 2),
(1, 'John Smith', '123 Main St.', 'Anytown', 'USA', 1, '2022-01-01', 100, 'Widget B', 1),
(1, 'John Smith', '123 Main St.', 'Anytown', 'USA', 2, '2022-02-01', 150, 'Widget C', 1),
(1, 'John Smith', '123 Main St.', 'Anytown', 'USA', 2, '2022-02-01', 150, 'Widget D', 2),
(2, 'Jane Doe', '456 Oak St.', 'Somewhere', 'USA', 3, '2022-03-01', 75, 'Widget A', 1),
(2, 'Jane Doe', '456 Oak St.', 'Somewhere', 'USA', 3, '2022-03-01', 75, 'Widget B', 2);

-- Insérer les données dans la table Customers
INSERT IGNORE INTO Customers (id, name, address, city, country)
SELECT DISTINCT 
    customer_id AS id,
    customer_name AS name,
    customer_address AS address,
    customer_city AS city,
    customer_country AS country
FROM customer_orders;

-- Insérer les données dans la table Orders_q11
INSERT IGNORE INTO Orders_q11 (id, customer_id, order_date, total)
SELECT DISTINCT
    order_id AS id,
    customer_id,
    order_date,
    order_total AS total
FROM customer_orders;

-- Insérer les données dans la table OrderDetails
INSERT INTO OrderDetails (id, order_id, product, quantity, price)
SELECT 
    (ROW_NUMBER() OVER ()) AS id,
    order_id,
    product_name AS product,
    order_quantity AS quantity,
    (order_total / order_quantity) AS price
FROM customer_orders;

-- Nettoyage
DROP TEMPORARY TABLE IF EXISTS customer_orders;