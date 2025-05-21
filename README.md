# Projet SQL - Base de données Sakila et Test Technique

Ce projet contient les solutions aux exercices SQL utilisant la base de données Sakila ainsi qu'un ensemble de réponses à des questions techniques sur SQL. Le projet est structuré en deux parties principales.

## Structure du Projet

- `sakila_sql_projet.sql` : Fichier contenant toutes les requêtes SQL et réponses
- `TEST SQL_25_26.pdf` : Fichier PDF contenant les instructions et les questions

## Prérequis

Pour exécuter les requêtes SQL de ce projet, vous aurez besoin de :

- MySQL Server (version 5.7 ou supérieure recommandée)
- La base de données Sakila installée
- Un client SQL (MySQL Workbench, phpMyAdmin, HeidiSQL, etc.)

## Installation de la Base de Données Sakila

La base de données Sakila est une base de données exemple fournie par MySQL. Pour l'installer :

1. Téléchargez les fichiers Sakila depuis le site officiel de MySQL : [Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/sakila-installation.html)
2. Exécutez les scripts SQL d'installation dans l'ordre suivant :
   - `sakila-schema.sql` (structure de la base)
   - `sakila-data.sql` (données)

```sql
SOURCE sakila-schema.sql;
SOURCE sakila-data.sql;
```

## Contenu du Projet

### Partie 1 : Base de données Sakila

Cette section contient 16 requêtes SQL qui explorent différents aspects de la base de données Sakila :

1. Recherche de films par titre
2. Filtrage de films par durée
3. Listage de films par langue et date de mise à jour
4. Jointures pour afficher les catégories et langues des films
5. Analyse des films les plus loués
6. Calcul du revenu total par film
7. Comparaison avec la moyenne
8. Filtrage par catégorie et nombre de locations
9. Identification des clients les plus rentables
10. Requêtes sur les DVD non retournés
11. Analyse des ventes mensuelles par magasin
12. Calcul des revenus par employé
13. Création de vues pour les films populaires
14. Création de vues pour les clients VIP
15. Opérations d'insertion et de suppression
16. Requêtes complexes avec plusieurs jointures

### Partie 2 : Test Technique (type entreprise)

Cette section contient les réponses à 11 questions techniques sur SQL :

1. Comment optimiser les requêtes SQL
2. Comment supprimer les lignes en double d'une table
3. Différences entre HAVING et WHERE
4. Différence entre normalisation et dénormalisation
5. Différences entre DELETE et TRUNCATE
6. Comment empêcher les entrées en double
7. Les différents types de relations en SQL
8. Insertion de données dans des tables et requête sur le nombre d'étudiants par cours
9. Requêtes sur la table Orders
10. Requête sur la quantité totale vendue par produit
11. Insertion de données de commandes clients dans trois tables liées

## Exécution des Requêtes

Pour exécuter les requêtes du projet :

1. Assurez-vous que votre serveur MySQL est en cours d'exécution
2. Connectez-vous à votre instance MySQL
3. Sélectionnez la base de données Sakila :
   ```sql
   USE sakila;
   ```
4. Exécutez les requêtes individuellement ou le fichier entier selon vos besoins

## Résolution des Problèmes Courants

### Erreur "Table doesn't exist"
Vérifiez que la base de données Sakila est correctement installée :
```sql
SHOW DATABASES;
USE sakila;
SHOW TABLES;
```

### Problèmes avec les Tables Temporaires
Si vous rencontrez des erreurs liées aux tables temporaires, exécutez :
```sql
DROP TEMPORARY TABLE IF EXISTS customer_orders;
DROP TEMPORARY TABLE IF EXISTS temp_employes;
```

### Résultats Non Affichés
Si les résultats ne s'affichent pas dans votre client SQL :
- Vérifiez les paramètres d'affichage des résultats
- Essayez d'exécuter les requêtes individuellement
- Confirmez que vous êtes bien connecté à la base de données Sakila

## Auteurs

- Jiwon
- Jordan

## Licence

Ce projet est destiné à des fins éducatives uniquement.
