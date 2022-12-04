--Question 1, création des tables

CREATE DATABASE BDTourismo;
USE BDTourismo;

CREATE TABLE villes
(
CodeVille char(3) PRIMARY KEY,
NomVille varchar(50) NOT NULL,
"Population" int
);

CREATE TABLE monuments
(
IdMonument int IDENTITY(2, 1) PRIMARY KEY,
NomMonument varchar(30) NOT NULL,
HistoireMonument varchar(60) NOT NULL,
NbEtoile smallint NOT NULL,
CoutVisite money NOT NULL
);

CREATE TABLE circuits
(
IdCircuit int identity(51, 1) PRIMARY KEY,
NomCircuit varchar(30) NOT NULL,
DureeCircuit int NOT NULL, 
CoutCircuit money NOT NULL,
NbMaxClients smallint,
CodeVilleDebut char(3) NOT NULL FOREIGN KEY REFERENCES Villes(codeVille),
CodeVilleFin char(3) NOT NULL FOREIGN KEY REFERENCES Villes(codeVille)
);

CREATE TABLE circuitsmonuments
(
IdMonument int NOT NULL,
IdCircuit int NOT NULL,
OrdreDeVisite smallint
);

/*
Question 2, écriture des requêtes
a. Ajouter la contrainte de clé primaire à la table CircuitsMonuments. La clé primaire
de cette table est (idmonument, idcircuit) 
*/

ALTER TABLE circuitsmonuments
ADD PRIMARY KEY (IdMonument, IdCircuit);

/*
b. Ajouter les contraintes de clé étrangère pour la table circuitsmonuments comme
suit :
• IdMonument est une clé étrangère faisant référence à idmonument de la table
monuments
• IdCircuit est une clé étrangère faisant référence à IdCircuit de la table circuits
*/

ALTER TABLE circuitsmonuments 
ADD FOREIGN KEY (IdMonument) REFERENCES monuments(IdMonument);

ALTER TABLE circuitsmonuments 
ADD FOREIGN KEY (IdCircuit) REFERENCES circuits(IdCircuit);

--2- Ajoutez les contraintes suivantes : Le nombre d’étoiles doit être entre 1 et 5.

ALTER TABLE monuments
ADD CONSTRAINT NbEtoilesRequis CHECK (NbEtoile between 1 and 5);

--3- Exécutez le script Tourismo.sql pour faire les différentes insertions

begin transaction;

insert into villes values('MTL', 'Montréal',2000000);
insert into villes values('QUE', 'Québec',1500000);
insert into villes values('OTT','Ottawa',10000000);
insert into villes values ('TOR','Toronto',3000000); 
--------------------------------------------

insert into monuments values('Oratoire St-Josephe','L''oratoire Saint-Joseph est une église à Montréal',5,'20');
insert into monuments values('Basilique notre dame','L''église-mère de Montréal',4,10);
insert into monuments values('Beaux Art','Musé de Montréal',4,100);
insert into monuments values('Le château Frontenac','L''hôtel du Parlement du Québec',5,150); 
insert into monuments values('Jardin Botanique','Le Jardin botanique de Montréal',3,50);
insert into monuments values('Parlement de Quebec','Le parlement de Quebec',4,50);
insert into monuments values('Le Parelemt D''Ottawa','Le parlement de Ottawa',4,50);
insert into monuments values('Le Phare','Le Phare de Gatineau',2,10);
insert into monuments values('Le Panthéon','Le Panthéon du Hockey',3,60);
insert into monuments values('Le Musé','Le musé de la 2eme guere mondiale',4,50);
insert into monuments values('La Citadelle','La citadelle de Quebec',5,20);
insert into monuments values('Le Chateau','Le Chateau de Toronto',2,20);
-------

insert into circuits values('Le MontMartre',7,400,50,'MTL','QUE');
insert into circuits values('Le Patoche',10,500,20,'MTL','TOR');
insert into circuits values('Le Barackuda',5,300,40,'MTL','OTT');
insert into circuits values('Le Primogene',6,300,20,'QUE','MTL');
insert into circuits values('Le Jaguar',4,200,10,'QUE','OTT');
---

insert into circuitsmonuments values(2,51,1);
insert into circuitsmonuments values(3,51,2);
insert into circuitsmonuments values(5,51,3);
insert into circuitsmonuments values(7,51,4);
insert into circuitsmonuments values(8,51,5);
insert into circuitsmonuments values(12,51,6);
insert into circuitsmonuments values(2,52,1);
insert into circuitsmonuments values(4,52,2);
insert into circuitsmonuments values(10,52,3);
insert into circuitsmonuments values(11,52,4);
insert into circuitsmonuments values(2,53,1);
insert into circuitsmonuments values(3,53,2);
insert into circuitsmonuments values(8,53,3);
insert into circuitsmonuments values(11,53,4);
insert into circuitsmonuments values(9,53,5);
insert into circuitsmonuments values(5,55,1);
insert into circuitsmonuments values(9,55,1);
insert into circuitsmonuments values(11,55,1);
commit;

/*
4- Écrire les requêtes suivantes :
a. La liste des circuits dont la ville de départ est ‘Montréal’. Afficher le nom du
circuit, le nom de la ville de départ, le nom de la ville d’arrivée, le prix du circuit).
*/

SELECT c.NomCircuit, v1.NomVille AS 'Nom ville de départ', v2.NomVille AS 'Nom ville d''arrivée', c.CoutCircuit
FROM circuits c JOIN 
villes v1
ON c.CodeVilleDebut = v1.CodeVille JOIN
villes v2
ON c.CodeVilleFin = v2.CodeVille
WHERE v1.NomVille = 'Montréal';

/*
b. Liste des circuits offerts par l’agence; tous les circuits. Cette liste doit être
ordonnée par la cotation (la somme du nombre d’étoiles dans un circuit).
Afficher le nom du circuit, le nom de la ville de début, le nom de la ville
d’arrivée, le prix du circuit.
*/

SELECT c.NomCircuit, v1.NomVille AS 'Nom ville de départ', v2.NomVille AS 'Nom ville d''arrivée', c.CoutCircuit
FROM circuits c JOIN 
villes v1
ON c.CodeVilleDebut = v1.CodeVille JOIN
villes v2
ON c.CodeVilleFin = v2.CodeVille JOIN
CircuitsMonuments cm
ON c.IdCircuit = cm.IdCircuit JOIN
monuments m
ON cm.IdMonument = m.IdMonument
GROUP BY c.NomCircuit, v1.NomVille, v2.NomVille, c.CoutCircuit
ORDER BY SUM(m.NbEtoile) DESC;

/*
c. Quels sont les monuments qui ne sont sur aucun circuit (afficher le nom du
monument et le nombre d’étoiles)
*/

SELECT NomMonument, NbEtoile
FROM monuments as m LEFT JOIN 
circuitsmonuments cm
ON m.IdMonument = cm.IdMonument
WHERE cm.IdMonument IS NULL;

/*
d. Afficher la liste des circuits ayant le nombre total d’étoiles plus grand ou égal à
15. Afficher le nom du circuit, le nombre total d’étoiles;
*/

SELECT SUM(m.NbEtoile) as 'Total d''étoiles', c.NomCircuit
FROM circuits c JOIN 
circuitsmonuments cm
ON c.IdCircuit = cm.IdCircuit JOIN
monuments m
ON cm.IdMonument = m.IdMonument
GROUP BY c.NomCircuit
HAVING SUM(m.NbEtoile) >= 15
ORDER BY SUM(m.NbEtoile) DESC;

/*
e. Liste des 2 meilleurs circuits selon le nombre total d’étoiles. Afficher le nom
circuit, le nombre total d’étoiles du circuit, les noms des villes de début et des
villes fin
*/

SELECT TOP 2 SUM(m.NbEtoile) as 'Total étoiles', v1.NomVille as 'Ville de départ', v2.NomVille as 'Ville d''arrivée'
FROM circuits c JOIN 
villes v1
ON c.CodeVilleDebut = v1.codeVille JOIN
villes v2
ON c.CodeVilleFin = v2.codeVille JOIN
circuitsmonuments cm
ON c.IdCircuit = cm.IdCircuit JOIN
monuments m
ON cm.IdMonument = m.IdMonument
GROUP BY v1.NomVille, v2.NomVille
ORDER BY SUM(NbEtoile) DESC;

/*
f. Quels sont les monuments qui sont dans plus que deux circuits. Afficher le nom
du monument, le nombre d’étoiles et l’histoire du monument
*/

SELECT NomMonument, NbEtoile, HistoireMonument
FROM monuments m
JOIN circuitsmonuments cm
ON m.IdMonument = cm.IdMonument
GROUP BY NomMonument, NbEtoile, HistoireMonument
HAVING COUNT(cm.IdMonument) > 2;

/*
g. Créez la vue, VMonuments dont les colonnes sont (nomCircuit, nomMonument,
ordreDevisite, nbEtoile, et le coutcircuit)
*/

CREATE VIEW VMonuments AS
SELECT c.NomCircuit, m.NomMonument, cm.OrdreDeVisite, m.NbEtoile, c.CoutCircuit
FROM circuits c JOIN
circuitsmonuments cm
ON c.IdCircuit = cm.IdCircuit JOIN
monuments m
ON cm.IdMonument = m.IdMonument
GROUP BY c.NomCircuit, m.NomMonument, cm.OrdreDeVisite, m.NbEtoile, c.CoutCircuit;

/*
h. Utiliser la vue VMonuments pour afficher la liste des monuments dont le
nombre d’étoiles est supérieur ou égal à 4. Les résultats doivent-être ordonnés
selon le nomCircuit ;
*/

SELECT * From VMonuments VM
WHERE VM.NbEtoile >= 4
ORDER BY VM.NomCircuit;

/*
5- Mettre à jour la table circuits comme suit :
a. Si le cout du circuit est plus petit ou égal que 250, on augmente de 10% de son
coût initial.
*/

UPDATE circuits 
SET circuits.CoutCircuit = circuits.CoutCircuit * 1.10
WHERE circuits.CoutCircuit <= 250;

--b. Si le coût est compris entre 250 et 450 on augmente de 5% de son coût initial.

UPDATE circuits 
SET circuits.CoutCircuit = circuits.CoutCircuit * 1.05
WHERE circuits.CoutCircuit BETWEEN 250 AND 450;

--c. Sinon on augmente de 1% de son coût initial.

UPDATE circuits 
SET circuits.CoutCircuit = circuits.CoutCircuit * 1.01
WHERE circuits.CoutCircuit > 450;

/*
6- Mettre à jour la table Monuments comme suit :
On augmente le coût de la visite guidée de 5% de son coût initial tant que la moyenne
des coûts est plus petite ou égale à 80 et que le maximum des coûts n’est pas atteint.
Ce maximum est de 250.
*/

WHILE (SELECT AVG(CoutVisite) FROM monuments) <= 80 AND (SELECT MAX(CoutVisite) FROM monuments) < 250 
BEGIN
	UPDATE monuments
	SET	monuments.CoutVisite = monuments.CoutVisite * 1.05
END
;

/*
Question 3, compréhension 
1. Dans la table Monuments, insérez l’enregistrement suivant :
(100,'La statue','La statue de bronze',2,20);
Pour cela vous devez mettre INDENTITY_INSERT à ON
*/


SET IDENTITY_INSERT BDTourismo.dbo.monuments ON
INSERT INTO monuments(IdMonument, NomMonument,HistoireMonument,NbEtoile,CoutVisite)
VALUES (100,'La statue','La statue de bronze',2,20);

/*
2. Remettez à nouveau INDENTITY_INSERT à OFF puis insérer un autre enregistrement de
votre choix. Quelle est la valeur de la clé primaire pour cet enregistrement ? Qu’est-ce
que nous pouvons conclure ?
*/

SET IDENTITY_INSERT BDTourismo.dbo.monuments OFF
INSERT INTO monuments(IdMonument,NomMonument, HistoireMonument, NbEtoile, CoutVisite)
VALUES('Xochicalo', 'Xochicalco est un site archéologique au Mexique', 5, 5.57);

/*
Nous pouvons en conclure que lorsque IDENTITY_INSERT est OFF, 
la clef primaire de notre nouvelle ligne sera auto incrémentée
à partir de la valeur de la dernière clef 

3. Dans la table circuitsmonuments , pensez-vous que nous aurions pu déclarer Idcircuit
ou idmonument avec l’option INDENTITY ? Justifiez votre réponse

Non car ce sont des clefs étrangères, donc dépendantent de leur table d'origine

4. De manière générale, qu’avez-vous retenu de ce laboratoire ?

J'ai retenu de ce laboratoire que la manière la plus efficace pour faire des requêtes 
sur plusieurs tables sans modifier la base de donnée, est d'employer la fonction
VIEW
*/