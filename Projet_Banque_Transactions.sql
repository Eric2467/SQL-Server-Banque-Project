USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'BANQUE')
    DROP DATABASE BANQUE;
GO
CREATE DATABASE BANQUE
    COLLATE French_CI_AS;
GO

USE BANQUE;
GO

CREATE TABLE Agence (
    id_agence       INT             IDENTITY(1,1)   PRIMARY KEY,
    nom_agence      VARCHAR(100)    NOT NULL,
    adresse         VARCHAR(200)    NOT NULL,
    ville           VARCHAR(100)    NOT NULL,
    telephone       VARCHAR(20)     NOT NULL    UNIQUE,
    code_agence     CHAR(6)         NOT NULL    UNIQUE
        CONSTRAINT CHK_code_agence CHECK (code_agence LIKE 'AG[0-9][0-9][0-9]')
);
GO

CREATE TABLE Employe (
    id_employe      INT             IDENTITY(1,1)   PRIMARY KEY,
    nom             VARCHAR(80)     NOT NULL,
    prenom          VARCHAR(80)     NOT NULL,
    poste           VARCHAR(80)     NOT NULL,
    salaire         DECIMAL(15,2)   NOT NULL
        CONSTRAINT CHK_salaire CHECK (salaire > 0),
    date_embauche   DATE            NOT NULL
        CONSTRAINT CHK_date_embauche CHECK (date_embauche <= CAST(GETDATE() AS DATE)),
    telephone       VARCHAR(20)     NOT NULL    UNIQUE,
    email           VARCHAR(150)                UNIQUE,
    id_agence       INT             NOT NULL,
    CONSTRAINT FK_Employe_Agence FOREIGN KEY (id_agence) REFERENCES Agence(id_agence)
);
GO

CREATE TABLE Client (
    id_client       INT             IDENTITY(1,1)   PRIMARY KEY,
    nom             VARCHAR(80)     NOT NULL,
    prenom          VARCHAR(80)     NOT NULL,
    date_naissance  DATE            NOT NULL
        CONSTRAINT CHK_age_client CHECK (
            DATEDIFF(YEAR, date_naissance, GETDATE()) >= 18
        ),
    adresse         VARCHAR(200)    NOT NULL,
    ville           VARCHAR(100)    NOT NULL        DEFAULT 'Brazzaville',
    telephone       VARCHAR(20)     NOT NULL    UNIQUE,
    email           VARCHAR(150)                UNIQUE,
    date_creation   DATE            NOT NULL        DEFAULT CAST(GETDATE() AS DATE),
    numero_cin      VARCHAR(30)     NOT NULL    UNIQUE
);
GO

CREATE TABLE Compte (
    id_compte       INT             IDENTITY(1,1)   PRIMARY KEY,
    numero_compte   CHAR(12)        NOT NULL    UNIQUE,
    type_compte     VARCHAR(30)     NOT NULL
        CONSTRAINT CHK_type_compte CHECK (type_compte IN ('Courant', 'Épargne', 'Joint')),
    solde           DECIMAL(18,2)   NOT NULL        DEFAULT 0.00
        CONSTRAINT CHK_solde_positif CHECK (solde >= 0),
    date_ouverture  DATE            NOT NULL        DEFAULT CAST(GETDATE() AS DATE),
    statut          VARCHAR(20)     NOT NULL        DEFAULT 'Actif'
        CONSTRAINT CHK_statut_compte CHECK (statut IN ('Actif', 'Bloqué', 'Clôturé')),
    id_client       INT             NOT NULL,
    id_agence       INT             NOT NULL,
    CONSTRAINT FK_Compte_Client FOREIGN KEY (id_client) REFERENCES Client(id_client),
    CONSTRAINT FK_Compte_Agence FOREIGN KEY (id_agence) REFERENCES Agence(id_agence)
);
GO

CREATE TABLE Operation (
    id_operation        INT             IDENTITY(1,1)   PRIMARY KEY,
    type_operation      VARCHAR(30)     NOT NULL
        CONSTRAINT CHK_type_operation CHECK (
            type_operation IN ('Dépôt', 'Retrait', 'Virement entrant', 'Virement sortant')
        ),
    montant             DECIMAL(18,2)   NOT NULL
        CONSTRAINT CHK_montant_positif CHECK (montant > 0),
    date_operation      DATETIME        NOT NULL        DEFAULT GETDATE(),
    description         VARCHAR(255),
    id_compte           INT             NOT NULL,
    CONSTRAINT FK_Operation_Compte FOREIGN KEY (id_compte) REFERENCES Compte(id_compte)
);
GO

CREATE TABLE Audit_Operations (
    id_audit            INT             IDENTITY(1,1)   PRIMARY KEY,
    id_operation        INT,
    id_compte           INT,
    type_operation      VARCHAR(30),
    montant             DECIMAL(18,2),
    solde_avant         DECIMAL(18,2),
    solde_apres         DECIMAL(18,2),
    date_audit          DATETIME        DEFAULT GETDATE(),
    utilisateur         VARCHAR(100)    DEFAULT SYSTEM_USER
);
GO

INSERT INTO Agence (nom_agence, adresse, ville, telephone, code_agence) VALUES
('Agence Centrale',         '12 Avenue de l''Indépendance',  'Brazzaville',  '06 600 0001', 'AG001'),
('Agence Poto-Poto',        '45 Rue Mbochi',                 'Brazzaville',  '06 600 0002', 'AG002'),
('Agence Bacongo',          '3 Boulevard Lyautey',           'Brazzaville',  '06 600 0003', 'AG003'),
('Agence Pointe-Noire',     '18 Avenue du Port',             'Pointe-Noire', '06 600 0004', 'AG004'),
('Agence Ouesso',           '7 Rue de la Forêt',             'Ouesso',       '06 600 0005', 'AG005');
GO

INSERT INTO Employe (nom, prenom, poste, salaire, date_embauche, telephone, email, id_agence) VALUES
('MOUKALA',     'Jean-Pierre',  'Directeur d''agence',  850000,  '2018-03-15', '06 601 0001', 'jmoukala@banque.cg',    1),
('MBOUNGOU',    'Marie',        'Caissière',            420000,  '2019-07-10', '06 601 0002', 'mmboungou@banque.cg',   1),
('NZINGA',      'Patrick',      'Chargé de clientèle',  520000,  '2020-01-20', '06 601 0003', 'pnzinga@banque.cg',     1),
('LOEMBA',      'Sophie',       'Comptable',            580000,  '2017-09-05', '06 601 0004', 'sloemba@banque.cg',     1),
('BAKALA',      'Théodore',     'Agent de sécurité',    350000,  '2021-04-12', '06 601 0005', 'tbakala@banque.cg',     1),
('NTSOUMOU',    'Ghislaine',    'Directeur d''agence',  850000,  '2016-06-01', '06 601 0006', 'gntsoumou@banque.cg',   2),
('MALONGA',     'Rodrigue',     'Caissier',             420000,  '2022-02-28', '06 601 0007', 'rmalonga@banque.cg',    2),
('MOUKOUYOU',   'Clarisse',     'Chargée de clientèle', 520000,  '2020-11-15', '06 601 0008', 'cmoukouyou@banque.cg',  2),
('ITOUA',       'Fabrice',      'Informaticien',        620000,  '2019-03-22', '06 601 0009', 'fitoua@banque.cg',      2),
('BOUKOUNGOU',  'Angèle',       'Secrétaire',           380000,  '2021-08-09', '06 601 0010', 'aboukoungou@banque.cg', 2),
('GANDZOU',     'Hervé',        'Directeur d''agence',  850000,  '2015-01-10', '06 601 0011', 'hgandzou@banque.cg',    3),
('NKOUKA',      'Véronique',    'Caissière',            420000,  '2023-05-14', '06 601 0012', 'vnkouka@banque.cg',     3),
('LOUBELO',     'Serge',        'Chargé de clientèle',  520000,  '2018-10-30', '06 601 0013', 'slobelo@banque.cg',     3),  -- Correction: LOUBELO correct
('MAKOSSO',     'Aurore',       'Comptable',            580000,  '2020-06-17', '06 601 0014', 'amakosso@banque.cg',    3),
('NGOUARI',     'Gildas',       'Agent de sécurité',    350000,  '2022-09-01', '06 601 0015', 'gngouari@banque.cg',    3),
('MOUANDA',     'Lambert',      'Directeur d''agence',  870000,  '2014-04-20', '06 601 0016', 'lmouanda@banque.cg',    4),
('KIBANGOU',    'Nadège',       'Caissière',            420000,  '2021-12-05', '06 601 0017', 'nkibangou@banque.cg',   4),
('LOUSSOUKOU',  'Éric',         'Informaticien',        630000,  '2019-07-18', '06 601 0018', 'eloussoukou@banque.cg', 4),
('MOUYABI',     'Francine',     'Directeur d''agence',  850000,  '2017-02-14', '06 601 0019', 'fmouyabi@banque.cg',    5),
('OPIMBA',      'Christian',    'Caissier',             420000,  '2023-01-09', '06 601 0020', 'copimba@banque.cg',     5);
GO

INSERT INTO Client (nom, prenom, date_naissance, adresse, ville, telephone, email, date_creation, numero_cin) VALUES
('MOUKALA',     'Christelle',   '1990-05-12', '14 Rue Mbochi',                'Brazzaville',  '06 700 0001', 'cmoukala@gmail.com',       '2022-01-15', 'CIN00000001'),
('BIYOUDI',     'Alexandre',    '1985-08-23', '28 Avenue de France',          'Brazzaville',  '06 700 0002', 'abiyoudi@gmail.com',       '2021-03-10', 'CIN00000002'),
('NZOUZI',      'Patience',     '1992-11-03', '5 Rue de Bacongo',             'Brazzaville',  '06 700 0003', 'pnzouzi@gmail.com',        '2020-07-22', 'CIN00000003'),
('IBARA',       'Gaston',       '1978-02-17', '33 Boulevard Denis Sassou',    'Brazzaville',  '06 700 0004', 'gibara@gmail.com',         '2019-11-05', 'CIN00000004'),
('KIMBEMBE',    'Rosalie',      '1995-07-30', '9 Rue de la Paix',             'Brazzaville',  '06 700 0005', 'rkimbembe@gmail.com',      '2023-02-18', 'CIN00000005'),
('MOUSSODJI',   'Narcisse',     '1988-04-09', '17 Rue Marien Ngouabi',        'Brazzaville',  '06 700 0006', 'nmoussodji@gmail.com',     '2022-06-30', 'CIN00000006'),
('NTSIKA',      'Élise',        '1993-12-25', '4 Allée des Bougainvilliers',  'Brazzaville',  '06 700 0007', 'entsika@gmail.com',        '2021-09-14', 'CIN00000007'),
('MAVOUNGOU',   'Josué',        '1980-01-11', '21 Rue Félix Eboué',           'Brazzaville',  '06 700 0008', 'jmavoungou@gmail.com',     '2020-04-03', 'CIN00000008'),
('LISSANGA',    'Bibiane',      '1997-06-14', '8 Rue des Jasmins',            'Pointe-Noire', '06 700 0009', 'blissanga@gmail.com',      '2023-08-21', 'CIN00000009'),
('ELENGA',      'Rodrigue',     '1983-09-28', '12 Avenue du Chemin de Fer',   'Pointe-Noire', '06 700 0010', 'relenga@gmail.com',        '2019-05-17', 'CIN00000010'),
('BOUITI',      'Mireille',     '1991-03-07', '36 Rue de la Côte Sauvage',    'Pointe-Noire', '06 700 0011', 'mbouiti@gmail.com',        '2022-10-29', 'CIN00000011'),
('KAYA',        'Hermann',      '1986-07-19', '2 Avenue Agostinho Neto',      'Pointe-Noire', '06 700 0012', 'hkaya@gmail.com',          '2021-01-08', 'CIN00000012'),
('NKOUNKOU',    'Adèle',        '1998-10-05', '19 Rue des Palmiers',          'Ouesso',       '06 700 0013', 'ankounkou@gmail.com',      '2024-03-12', 'CIN00000013'),
('MAKAYA',      'Théophile',    '1975-12-20', '7 Boulevard de la Sangha',     'Ouesso',       '06 700 0014', 'tmakaya@gmail.com',        '2018-08-25', 'CIN00000014'),
('BIKOUTA',     'Lydie',        '1994-02-28', '25 Rue du Commerce',           'Brazzaville',  '06 700 0015', 'lbikouta@gmail.com',       '2023-11-04', 'CIN00000015'),
('NGAMBOU',     'Wilfrid',      '1989-05-16', '11 Avenue des Trois Martyrs',  'Brazzaville',  '06 700 0016', 'wngambou@gmail.com',       '2020-02-19', 'CIN00000016'),
('MPASSI',      'Glaucia',      '1996-08-08', '6 Rue de l''Équateur',         'Brazzaville',  '06 700 0017', 'gmpassi@gmail.com',        '2024-01-07', 'CIN00000017'),
('TCHILOULA',   'Lionel',       '1982-11-22', '30 Avenue de la Libération',   'Brazzaville',  '06 700 0018', 'ltchiloula@gmail.com',     '2019-09-13', 'CIN00000018'),
('BOUANGA',     'Joëlle',       '1990-04-04', '43 Rue de Talangaï',           'Brazzaville',  '06 700 0019', 'jbouanga@gmail.com',       '2021-06-26', 'CIN00000019'),
('MOUNDZEGOU',  'Cédric',       '1987-01-30', '16 Rue des Ecoles',            'Brazzaville',  '06 700 0020', 'cmoundzegou@gmail.com',    '2022-12-01', 'CIN00000020'),
('OSSIELE',     'Flore',        '1993-07-17', '53 Rue de Poto-Poto',          'Brazzaville',  '06 700 0021', 'fossiele@gmail.com',       '2023-04-15', 'CIN00000021'),
('NGANGA',      'Martial',      '1979-03-12', '8 Avenue de la République',    'Brazzaville',  '06 700 0022', 'mnganga@gmail.com',        '2018-01-20', 'CIN00000022'),
('LOUBAMONO',   'Yvette',       '1984-06-25', '22 Rue Kikounga-Ngot',         'Brazzaville',  '06 700 0023', 'yloubamono@gmail.com',     '2020-10-08', 'CIN00000023'),
('MOUKALA',     'Franck',       '1991-09-09', '31 Rue Karl Marx',             'Pointe-Noire', '06 700 0024', 'fmoukala2@gmail.com',      '2022-05-22', 'CIN00000024'),
('KIMINOU',     'Pascaline',    '1999-12-01', '47 Boulevard du Général',      'Pointe-Noire', '06 700 0025', 'pkiminou@gmail.com',       '2024-02-09', 'CIN00000025'),
('KILOUTA',     'Aristide',     '1976-04-18', '3 Rue Savorgnan de Brazza',    'Brazzaville',  '06 700 0026', 'akilouta@gmail.com',       '2017-06-14', 'CIN00000026'),
('MBEMBA',      'Christiane',   '1988-10-10', '10 Rue de la Tsiémé',          'Brazzaville',  '06 700 0027', 'cmbemba@gmail.com',        '2021-11-30', 'CIN00000027'),
('LOUZOLO',     'Thierry',      '1995-01-27', '18 Avenue des Écoles',         'Brazzaville',  '06 700 0028', 'tlouzolo@gmail.com',       '2023-07-04', 'CIN00000028'),
('NGOUOLALI',   'Sandrine',     '1981-08-14', '27 Rue de la Mission',         'Ouesso',       '06 700 0029', 'sngouolali@gmail.com',     '2019-03-28', 'CIN00000029'),
('BANZOUZI',    'Médard',       '1970-11-06', '9 Rue du Marché Central',      'Brazzaville',  '06 700 0030', 'mbanzouzi@gmail.com',      '2015-04-10', 'CIN00000030');
GO

INSERT INTO Compte (numero_compte, type_compte, solde, date_ouverture, statut, id_client, id_agence) VALUES
('BZV001000001', 'Courant',  2500000.00,     '2022-01-15',   'Actif',    1,  1),
('BZV001000002', 'Épargne',  15000000.00,    '2022-01-15',   'Actif',    1,  1),
('BZV001000003', 'Courant',  8750000.00,     '2021-03-10',   'Actif',    2,  1),
('BZV001000004', 'Épargne',  22000000.00,    '2021-03-10',   'Actif',    2,  1),
('BZV001000005', 'Courant',  1200000.00,     '2020-07-22',   'Actif',    3,  1),
('BZV002000006', 'Courant',  4500000.00,     '2019-11-05',   'Actif',    4,  2),
('BZV002000007', 'Épargne',  12500000.00,    '2019-11-05',   'Actif',    4,  2),
('BZV002000008', 'Joint',    6300000.00,     '2023-02-18',   'Actif',    5,  2),
('BZV002000009', 'Courant',  3100000.00,     '2022-06-30',   'Actif',    6,  2),
('BZV002000010', 'Épargne',  9800000.00,     '2021-09-14',   'Actif',    7,  2),
('BZV003000011', 'Courant',  750000.00,      '2020-04-03',   'Actif',    8,  3),
('BZV003000012', 'Épargne',  18500000.00,    '2020-04-03',   'Actif',    8,  3),
('BZV003000013', 'Courant',  2200000.00,     '2023-08-21',   'Actif',    9,  3),
('BZV004000014', 'Courant',  5600000.00,     '2019-05-17',   'Actif',    10, 4),
('BZV004000015', 'Épargne',  31000000.00,    '2019-05-17',   'Actif',    10, 4),
('BZV004000016', 'Courant',  1800000.00,     '2022-10-29',   'Actif',    11, 4),
('BZV004000017', 'Joint',    7400000.00,     '2021-01-08',   'Actif',    12, 4),
('BZV005000018', 'Courant',  900000.00,      '2024-03-12',   'Actif',    13, 5),
('BZV005000019', 'Épargne',  4200000.00,     '2018-08-25',   'Actif',    14, 5),
('BZV001000020', 'Courant',  3300000.00,     '2023-11-04',   'Actif',    15, 1),
('BZV001000021', 'Épargne',  11200000.00,    '2020-02-19',   'Actif',    16, 1),
('BZV002000022', 'Courant',  500000.00,      '2024-01-07',   'Actif',    17, 2),
('BZV002000023', 'Courant',  6700000.00,     '2019-09-13',   'Actif',    18, 2),
('BZV002000024', 'Épargne',  13400000.00,    '2021-06-26',   'Actif',    19, 2),
('BZV003000025', 'Courant',  2800000.00,     '2022-12-01',   'Actif',    20, 3),
('BZV003000026', 'Épargne',  7600000.00,     '2023-04-15',   'Actif',    21, 3),
('BZV003000027', 'Courant',  19500000.00,    '2018-01-20',   'Actif',    22, 3),
('BZV003000028', 'Joint',    5100000.00,     '2020-10-08',   'Actif',    23, 3),
('BZV004000029', 'Courant',  1600000.00,     '2022-05-22',   'Actif',    24, 4),
('BZV004000030', 'Épargne',  8900000.00,     '2024-02-09',   'Actif',    25, 4),
('BZV001000031', 'Courant',  45000000.00,    '2017-06-14',   'Actif',    26, 1),
('BZV001000032', 'Épargne',  28000000.00,    '2021-11-30',   'Actif',    27, 1),
('BZV002000033', 'Courant',  1100000.00,     '2023-07-04',   'Actif',    28, 2),
('BZV005000034', 'Épargne',  3700000.00,     '2019-03-28',   'Actif',    29, 5),
('BZV001000035', 'Courant',  67000000.00,    '2015-04-10',   'Actif',    30, 1),
('BZV001000036', 'Épargne',  52000000.00,    '2015-04-10',   'Actif',    30, 1),
('BZV002000037', 'Courant',  4100000.00,     '2021-03-10',   'Actif',    2,  2),
('BZV003000038', 'Joint',    9200000.00,     '2020-04-03',   'Actif',    8,  3),
('BZV004000039', 'Courant',  620000.00,      '2024-01-15',   'Actif',    13, 4),
('BZV005000040', 'Épargne',  2100000.00,     '2022-06-30',   'Actif',    6,  5);
GO

INSERT INTO Operation (type_operation, montant, date_operation, description, id_compte) VALUES
-- Compte 1 (id_client=1, Courant)
('Dépôt',               500000,     '2024-01-10 09:15:00', 'Salaire janvier',              1),
('Retrait',             200000,     '2024-01-15 14:30:00', 'Retrait guichet',              1),
('Virement sortant',    300000,     '2024-02-01 10:00:00', 'Loyer février',                1),
('Dépôt',               150000,     '2024-02-14 16:45:00', 'Remboursement',                1),
-- Compte 2 (id_client=1, Épargne)
('Dépôt',               2000000,    '2024-01-20 11:00:00', 'Placement mensuel',            2),
('Dépôt',               1500000,    '2024-03-01 09:30:00', 'Bonus annuel',                 2),
-- Compte 3 (id_client=2, Courant)
('Dépôt',               1000000,    '2024-01-05 08:00:00', 'Salaire',                      3),
('Retrait',             500000,     '2024-01-20 15:00:00', 'Retrait espèces',              3),
('Virement sortant',    800000,     '2024-02-10 10:30:00', 'Paiement fournisseur',         3),
('Dépôt',               600000,     '2024-02-25 09:00:00', 'Encaissement chèque',          3),
-- Compte 4 (id_client=2, Épargne)
('Dépôt',               5000000,    '2024-01-15 10:00:00', 'Investissement',               4),
('Dépôt',               3000000,    '2024-03-10 11:00:00', 'Épargne mensuelle',            4),
-- Compte 5 (id_client=3, Courant)
('Dépôt',               400000,     '2024-01-08 09:00:00', 'Salaire',                      5),
('Retrait',             100000,     '2024-01-25 12:00:00', 'Dépenses ménagères',           5),
('Dépôt',               250000,     '2024-02-08 09:00:00', 'Salaire',                      5),
-- Compte 6 (id_client=4, Courant)
('Dépôt',               800000,     '2024-01-12 10:00:00', 'Commerce',                     6),
('Retrait',             300000,     '2024-01-30 14:00:00', 'Retrait',                      6),
('Virement entrant',    1200000,    '2024-02-15 11:00:00', 'Virement reçu',                6),
-- Compte 7 (id_client=4, Épargne)
('Dépôt',               2500000,    '2024-01-18 09:00:00', 'Placement',                    7),
('Dépôt',               2000000,    '2024-03-05 10:00:00', 'Placement',                    7),
-- Compte 8 (id_client=5, Joint)
('Dépôt',               1000000,    '2024-02-20 09:30:00', 'Salaires cumulés',             8),
('Retrait',             500000,     '2024-03-01 15:00:00', 'Loyer',                        8),
-- Compte 9 (id_client=6, Courant)
('Dépôt',               600000,     '2024-01-07 08:30:00', 'Salaire',                      9),
('Retrait',             200000,     '2024-01-22 13:00:00', 'Retrait',                      9),
('Dépôt',               400000,     '2024-02-07 08:30:00', 'Salaire',                      9),
-- Compte 10 (id_client=7, Épargne)
('Dépôt',               1800000,    '2024-01-10 10:00:00', 'Épargne',                      10),
('Dépôt',               1500000,    '2024-02-10 10:00:00', 'Épargne',                      10),
('Dépôt',               1000000,    '2024-03-10 10:00:00', 'Épargne',                      10),
-- Compte 11 (id_client=8, Courant)
('Dépôt',               300000,     '2024-01-05 09:00:00', 'Dépôt espèces',                11),
('Retrait',             150000,     '2024-01-20 12:00:00', 'Retrait',                      11),
-- Compte 12 (id_client=8, Épargne)
('Dépôt',               3000000,    '2024-01-25 10:00:00', 'Épargne mensuelle',            12),
('Dépôt',               2500000,    '2024-02-25 10:00:00', 'Épargne mensuelle',            12),
-- Compte 13 (id_client=9, Courant)
('Dépôt',               500000,     '2024-03-05 09:00:00', 'Virement reçu',                13),
('Retrait',             200000,     '2024-03-15 14:00:00', 'Retrait guichet',              13),
-- Compte 14 (id_client=10, Courant)
('Dépôt',               2000000,    '2024-01-03 08:00:00', 'Activité commerciale',         14),
('Retrait',             800000,     '2024-01-18 15:30:00', 'Retrait',                      14),
('Dépôt',               1500000,    '2024-02-03 08:00:00', 'Activité commerciale',         14),
('Retrait',             600000,     '2024-02-20 15:00:00', 'Retrait',                      14),
-- Compte 15 (id_client=10, Épargne)
('Dépôt',               5000000,    '2024-01-10 10:00:00', 'Placement important',          15),
('Dépôt',               4000000,    '2024-02-10 10:00:00', 'Placement',                    15),
('Dépôt',               3000000,    '2024-03-10 10:00:00', 'Placement',                    15),
-- Compte 16 (id_client=11, Courant)
('Dépôt',               400000,     '2024-01-15 09:00:00', 'Salaire',                      16),
('Retrait',             100000,     '2024-02-01 11:00:00', 'Retrait',                      16),
-- Compte 17 (id_client=12, Joint)
('Dépôt',               1500000,    '2024-01-20 10:00:00', 'Salaires cumulés',             17),
('Retrait',             700000,     '2024-02-05 14:00:00', 'Dépenses familiales',          17),
('Dépôt',               900000,     '2024-02-20 10:00:00', 'Salaires cumulés',             17),
-- Compte 18 (id_client=13, Courant)
('Dépôt',               300000,     '2024-03-13 09:30:00', 'Premier dépôt',                18),
-- Compte 19 (id_client=14, Épargne)
('Dépôt',               700000,     '2024-01-08 10:00:00', 'Épargne régulière',            19),
('Dépôt',               700000,     '2024-02-08 10:00:00', 'Épargne régulière',            19),
('Dépôt',               700000,     '2024-03-08 10:00:00', 'Épargne régulière',            19),
-- Compte 20 (id_client=15, Courant)
('Dépôt',               800000,     '2024-03-04 09:00:00', 'Salaire',                      20),
('Retrait',             300000,     '2024-03-18 13:00:00', 'Retrait',                      20),
-- Compte 21 (id_client=16, Épargne)
('Dépôt',               2000000,    '2024-01-19 10:00:00', 'Épargne',                      21),
('Dépôt',               1500000,    '2024-02-19 10:00:00', 'Épargne',                      21),
-- Compte 22 (id_client=17, Courant)
('Dépôt',               200000,     '2024-01-08 09:00:00', 'Premier dépôt',                22),
-- Compte 23 (id_client=18, Courant)
('Dépôt',               1200000,    '2024-01-13 09:00:00', 'Commerce',                     23),
('Retrait',             500000,     '2024-01-28 14:00:00', 'Retrait',                      23),
('Dépôt',               900000,     '2024-02-13 09:00:00', 'Commerce',                     23),
-- Compte 24 (id_client=19, Épargne)
('Dépôt',               3000000,    '2024-01-26 10:00:00', 'Épargne mensuelle',            24),
('Dépôt',               2500000,    '2024-02-26 10:00:00', 'Épargne mensuelle',            24),
('Dépôt',               2000000,    '2024-03-26 10:00:00', 'Épargne mensuelle',            24),
-- Compte 25 (id_client=20, Courant)
('Dépôt',               700000,     '2024-01-01 09:00:00', 'Salaire',                      25),
('Retrait',             200000,     '2024-01-16 12:00:00', 'Retrait',                      25),
-- Compte 26 (id_client=21, Épargne)
('Dépôt',               1500000,    '2024-01-15 10:00:00', 'Placement',                    26),
('Dépôt',               1200000,    '2024-03-15 10:00:00', 'Placement',                    26),
-- Compte 27 (id_client=22, Courant)
('Dépôt',               4000000,    '2024-01-18 08:00:00', 'Activité commerciale',         27),
('Retrait',             1500000,    '2024-02-02 15:00:00', 'Retrait important',            27),
('Dépôt',               3500000,    '2024-02-18 08:00:00', 'Activité commerciale',         27),
('Virement sortant',    1000000,    '2024-03-05 10:00:00', 'Transfert',                    27),
-- Compte 28 (id_client=23, Joint)
('Dépôt',               1000000,    '2024-01-08 10:00:00', 'Salaires',                     28),
('Retrait',             400000,     '2024-01-25 14:00:00', 'Dépenses',                     28),
-- Compte 29 (id_client=24, Courant)
('Dépôt',               500000,     '2024-01-22 09:00:00', 'Salaire',                      29),
('Retrait',             150000,     '2024-02-06 12:00:00', 'Retrait',                      29),
-- Compte 30 (id_client=25, Épargne)
('Dépôt',               2000000,    '2024-02-10 10:00:00', 'Placement',                    30),
('Dépôt',               1800000,    '2024-03-10 10:00:00', 'Placement',                    30),
-- Compte 31 (id_client=26, Courant VIP)
('Dépôt',               10000000,   '2024-01-16 08:00:00', 'Revenus entreprise',           31),
('Retrait',             3000000,    '2024-01-31 15:00:00', 'Retrait',                      31),
('Dépôt',               8000000,    '2024-02-16 08:00:00', 'Revenus entreprise',           31),
-- Compte 35 (id_client=30, Courant VIP)
('Dépôt',               15000000,   '2024-01-05 08:00:00', 'Revenus multiples',            35),
('Retrait',             5000000,    '2024-01-20 15:00:00', 'Retrait',                      35),
('Dépôt',               12000000,   '2024-02-05 08:00:00', 'Revenus multiples',            35),
('Virement sortant',    3000000,    '2024-02-28 10:00:00', 'Transfert international',      35),
-- Compte 36 (id_client=30, Épargne VIP)
('Dépôt',               10000000,   '2024-01-10 10:00:00', 'Épargne VIP',                  36),
('Dépôt',               8000000,    '2024-02-10 10:00:00', 'Épargne VIP',                  36),
('Dépôt',               6000000,    '2024-03-10 10:00:00', 'Épargne VIP',                  36),
-- Compte 37 (id_client=2, deuxième Courant)
('Dépôt',               900000,     '2024-02-05 09:00:00', 'Salaire',                      37),
('Retrait',             300000,     '2024-02-20 14:00:00', 'Retrait',                      37),
-- Compte 38 (id_client=8, Joint)
('Dépôt',               1800000,    '2024-01-28 10:00:00', 'Revenus locatifs',             38),
('Retrait',             600000,     '2024-02-15 14:00:00', 'Entretien',                    38);
GO

SELECT id_client, nom, prenom, date_naissance, adresse, ville,
       telephone, email, date_creation
FROM Client
ORDER BY nom, prenom;

SELECT numero_compte, type_compte,
       CAST(solde AS BIGINT) AS solde_FCFA,
       date_ouverture, statut
FROM Compte
WHERE solde > 5000000
ORDER BY solde DESC;

SELECT DISTINCT cl.id_client, cl.nom, cl.prenom,
       co.numero_compte, co.date_ouverture
FROM Client cl
INNER JOIN Compte co ON cl.id_client = co.id_client
WHERE co.date_ouverture > '2024-01-01'
ORDER BY co.date_ouverture;

DECLARE @NomRecherche VARCHAR(80) = 'MOUKALA';
SELECT id_client, nom, prenom, telephone, email, adresse
FROM Client
WHERE nom LIKE '%' + @NomRecherche + '%'
ORDER BY nom, prenom;

SELECT co.numero_compte, cl.nom, cl.prenom,
       co.solde, co.date_ouverture, a.nom_agence
FROM Compte co
INNER JOIN Client cl ON co.id_client = cl.id_client
INNER JOIN Agence a  ON co.id_agence = a.id_agence
WHERE co.type_compte = 'Épargne'
ORDER BY co.solde DESC;

SELECT id_client, nom, prenom, telephone, ville
FROM Client
ORDER BY nom ASC, prenom ASC;

SELECT COUNT(*) AS nb_total_comptes FROM Compte;

SELECT CAST(AVG(solde) AS DECIMAL(18,2)) AS solde_moyen_FCFA
FROM Compte;

SELECT TOP 1 co.numero_compte, co.type_compte, co.solde,
             cl.nom, cl.prenom, a.nom_agence
FROM Compte co
INNER JOIN Client cl ON co.id_client = cl.id_client
INNER JOIN Agence a  ON co.id_agence = a.id_agence
ORDER BY co.solde DESC;

SELECT CAST(SUM(solde) AS BIGINT) AS total_depots_FCFA
FROM Compte
WHERE statut = 'Actif';

SELECT cl.nom, cl.prenom,
       co.numero_compte, co.type_compte,
       CAST(co.solde AS BIGINT) AS solde_FCFA
FROM Client cl
INNER JOIN Compte co ON cl.id_client = co.id_client
ORDER BY cl.nom, cl.prenom, co.numero_compte;

SELECT cl.nom, cl.prenom,
       co.numero_compte,
       op.type_operation,
       CAST(op.montant AS BIGINT) AS montant_FCFA,
       op.date_operation,
       op.description
FROM Client cl
INNER JOIN Compte   co ON cl.id_client = co.id_client
INNER JOIN Operation op ON co.id_compte = op.id_compte
ORDER BY cl.nom, cl.prenom, op.date_operation;

SELECT a.nom_agence, a.ville,
       e.nom, e.prenom, e.poste,
       CAST(e.salaire AS BIGINT) AS salaire_FCFA
FROM Employe e
INNER JOIN Agence a ON e.id_agence = a.id_agence
ORDER BY a.nom_agence, e.nom;

SELECT cl.id_client, cl.nom, cl.prenom, cl.telephone
FROM Client cl
LEFT JOIN Compte co    ON cl.id_client = co.id_client
LEFT JOIN Operation op ON co.id_compte = op.id_compte
GROUP BY cl.id_client, cl.nom, cl.prenom, cl.telephone
HAVING COUNT(op.id_operation) = 0
ORDER BY cl.nom;

SELECT a.nom_agence, a.ville, COUNT(e.id_employe) AS nb_employes
FROM Agence a
INNER JOIN Employe e ON a.id_agence = e.id_agence
GROUP BY a.id_agence, a.nom_agence, a.ville
HAVING COUNT(e.id_employe) > 5
ORDER BY nb_employes DESC;

SELECT a.nom_agence, a.ville,
       COUNT(co.id_compte) AS nb_comptes,
       CAST(SUM(co.solde) AS BIGINT) AS total_soldes_FCFA
FROM Agence a
LEFT JOIN Compte co ON a.id_agence = co.id_agence
GROUP BY a.id_agence, a.nom_agence, a.ville
ORDER BY nb_comptes DESC;

SELECT cl.nom, cl.prenom,
       COUNT(op.id_operation)          AS nb_operations,
       CAST(SUM(op.montant) AS BIGINT) AS montant_total_FCFA
FROM Client cl
INNER JOIN Compte   co ON cl.id_client = co.id_client
INNER JOIN Operation op ON co.id_compte = op.id_compte
GROUP BY cl.id_client, cl.nom, cl.prenom
ORDER BY montant_total_FCFA DESC;

SELECT TOP 5
    cl.nom, cl.prenom,
    COUNT(op.id_operation) AS nb_operations
FROM Client cl
INNER JOIN Compte   co ON cl.id_client = co.id_client
INNER JOIN Operation op ON co.id_compte = op.id_compte
GROUP BY cl.id_client, cl.nom, cl.prenom
ORDER BY nb_operations DESC;

SELECT co.numero_compte, co.type_compte,
       CAST(co.solde AS BIGINT) AS solde_FCFA,
       cl.nom, cl.prenom,
       CAST((SELECT AVG(solde) FROM Compte) AS BIGINT) AS solde_moyen_FCFA
FROM Compte co
INNER JOIN Client cl ON co.id_client = cl.id_client
WHERE co.solde > (SELECT AVG(solde) FROM Compte)
ORDER BY co.solde DESC;

SELECT cl.nom, cl.prenom,
       COUNT(co.id_compte) AS nb_comptes,
       CAST(SUM(co.solde) AS BIGINT) AS solde_total_FCFA
FROM Client cl
INNER JOIN Compte co ON cl.id_client = co.id_client
GROUP BY cl.id_client, cl.nom, cl.prenom
HAVING COUNT(co.id_compte) > 2
ORDER BY nb_comptes DESC;

UPDATE Compte
SET    solde = solde + 500000
WHERE  numero_compte = 'BZV001000001';

INSERT INTO Operation (type_operation, montant, description, id_compte)
SELECT 'Dépôt', 500000, 'Dépôt manuel guichet', id_compte
FROM   Compte WHERE numero_compte = 'BZV001000001';

UPDATE Compte
SET    solde = solde - 300000
WHERE  numero_compte = 'BZV001000001';

INSERT INTO Operation (type_operation, montant, description, id_compte)
SELECT 'Retrait', 300000, 'Retrait manuel guichet', id_compte
FROM   Compte WHERE numero_compte = 'BZV001000001';

UPDATE Client
SET    adresse = '99 Avenue de la Justice',
       ville   = 'Brazzaville'
WHERE  id_client = 1;

UPDATE Client
SET    telephone = '06 799 9999'
WHERE  id_client = 1;

DELETE FROM Client
WHERE  id_client NOT IN (SELECT DISTINCT id_client FROM Compte);

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @montant_transfert  DECIMAL(18,2) = 1000000.00;
    DECLARE @num_source         CHAR(12)      = 'BZV001000001';
    DECLARE @num_dest           CHAR(12)      = 'BZV001000003';

    DECLARE @id_source  INT, @id_dest INT, @solde_source DECIMAL(18,2);

    -- Récupérer les identifiants et le solde source
    SELECT @id_source    = id_compte,
           @solde_source = solde
    FROM   Compte
    WHERE  numero_compte = @num_source
    AND    statut = 'Actif';

    SELECT @id_dest = id_compte
    FROM   Compte
    WHERE  numero_compte = @num_dest
    AND    statut = 'Actif';

    -- Vérification d'existence des comptes
    IF @id_source IS NULL
        THROW 50001, 'Compte source introuvable ou inactif.', 1;

    IF @id_dest IS NULL
        THROW 50002, 'Compte destinataire introuvable ou inactif.', 1;

    -- Vérification du solde suffisant
    IF @solde_source < @montant_transfert
        THROW 50003, 'Solde insuffisant pour effectuer le virement.', 1;

    -- Débit du compte source
    UPDATE Compte
    SET    solde = solde - @montant_transfert
    WHERE  id_compte = @id_source;

    -- Crédit du compte destinataire
    UPDATE Compte
    SET    solde = solde + @montant_transfert
    WHERE  id_compte = @id_dest;

    -- Enregistrement des deux opérations
    INSERT INTO Operation (type_operation, montant, description, id_compte)
    VALUES ('Virement sortant',  @montant_transfert, 'Virement vers ' + @num_dest,    @id_source),
           ('Virement entrant',  @montant_transfert, 'Virement reçu de ' + @num_source, @id_dest);

    COMMIT TRANSACTION;
    PRINT 'Virement de ' + CAST(@montant_transfert AS VARCHAR) + ' FCFA effectué avec succès.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERREUR — Transaction annulée : ' + ERROR_MESSAGE();
    -- Relancer l'erreur pour qu'elle remonte au niveau appelant
    THROW;
END CATCH;
GO

CREATE OR ALTER PROCEDURE sp_CreerCompte
    @id_client      INT,
    @id_agence      INT,
    @type_compte    VARCHAR(30),
    @solde_initial  DECIMAL(18,2) = 0.00
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation des paramètres
    IF @type_compte NOT IN ('Courant', 'Épargne', 'Joint')
    BEGIN
        RAISERROR('Type de compte invalide. Valeurs acceptées : Courant, Épargne, Joint.', 16, 1);
        RETURN;
    END;

    IF @solde_initial < 0
    BEGIN
        RAISERROR('Le solde initial ne peut pas être négatif.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Client WHERE id_client = @id_client)
    BEGIN
        RAISERROR('Client inexistant.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Agence WHERE id_agence = @id_agence)
    BEGIN
        RAISERROR('Agence inexistante.', 16, 1);
        RETURN;
    END;

    -- Génération du numéro de compte unique
    DECLARE @code_agence CHAR(6), @sequence VARCHAR(6), @numero_compte CHAR(12);

    SELECT @code_agence = code_agence FROM Agence WHERE id_agence = @id_agence;

    SELECT @sequence = RIGHT('000000' + CAST(COUNT(*) + 1 AS VARCHAR), 6)
    FROM   Compte WHERE id_agence = @id_agence;

    SET @numero_compte = LEFT(@code_agence, 3) + @sequence;

    -- Insertion du compte
    INSERT INTO Compte (numero_compte, type_compte, solde, date_ouverture, statut, id_client, id_agence)
    VALUES (@numero_compte, @type_compte, @solde_initial, CAST(GETDATE() AS DATE), 'Actif', @id_client, @id_agence);

    -- Enregistrement du dépôt initial si > 0
    IF @solde_initial > 0
    BEGIN
        INSERT INTO Operation (type_operation, montant, description, id_compte)
        VALUES ('Dépôt', @solde_initial, 'Dépôt d''ouverture de compte', SCOPE_IDENTITY());
    END;

    PRINT 'Compte créé avec succès. Numéro : ' + @numero_compte;
END;
GO

CREATE OR ALTER PROCEDURE sp_Depot
    @numero_compte  CHAR(12),
    @montant        DECIMAL(18,2),
    @description    VARCHAR(255) = 'Dépôt'
AS
BEGIN
    SET NOCOUNT ON;

    IF @montant <= 0
    BEGIN
        RAISERROR('Le montant du dépôt doit être supérieur à zéro.', 16, 1);
        RETURN;
    END;

    DECLARE @id_compte INT;

    SELECT @id_compte = id_compte
    FROM   Compte
    WHERE  numero_compte = @numero_compte AND statut = 'Actif';

    IF @id_compte IS NULL
    BEGIN
        RAISERROR('Compte introuvable ou inactif.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Compte
        SET    solde = solde + @montant
        WHERE  id_compte = @id_compte;

        INSERT INTO Operation (type_operation, montant, description, id_compte)
        VALUES ('Dépôt', @montant, @description, @id_compte);

        COMMIT TRANSACTION;
        PRINT 'Dépôt de ' + CAST(@montant AS VARCHAR) + ' FCFA effectué.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_Retrait
    @numero_compte CHAR(12),
    @montant       DECIMAL(18,2),
    @description   VARCHAR(255) = 'Retrait'
AS
BEGIN
    SET NOCOUNT ON;

    IF @montant <= 0
    BEGIN
        RAISERROR('Le montant doit etre superieur a zero.', 16, 1);
        RETURN;
    END;

    DECLARE @id_compte    INT;
    DECLARE @solde_actuel DECIMAL(18,2);

    SELECT @id_compte    = id_compte,
           @solde_actuel = solde
    FROM   Compte
    WHERE  numero_compte = @numero_compte AND statut = 'Actif';

    IF @id_compte IS NULL
    BEGIN
        RAISERROR('Compte introuvable ou inactif.', 16, 1);
        RETURN;
    END;

    IF @solde_actuel < @montant
    BEGIN
        DECLARE @msg_solde VARCHAR(100) = CAST(@solde_actuel AS VARCHAR) + ' FCFA';
        RAISERROR('Solde insuffisant. Solde disponible : %s', 16, 1, @msg_solde);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Compte
        SET    solde = solde - @montant
        WHERE  id_compte = @id_compte;

        INSERT INTO Operation (type_operation, montant, description, id_compte)
        VALUES ('Retrait', @montant, @description, @id_compte);

        COMMIT TRANSACTION;
        PRINT 'Retrait de ' + CAST(@montant AS VARCHAR) + ' FCFA effectue.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_ConsulterSolde
    @numero_compte CHAR(12)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Compte WHERE numero_compte = @numero_compte)
    BEGIN
        RAISERROR('Numéro de compte introuvable.', 16, 1);
        RETURN;
    END;

    SELECT
        co.numero_compte,
        co.type_compte,
        CAST(co.solde AS BIGINT)        AS solde_FCFA,
        co.statut,
        co.date_ouverture,
        cl.nom                          AS nom_client,
        cl.prenom                       AS prenom_client,
        a.nom_agence,
        (
            SELECT COUNT(*)
            FROM   Operation op
            WHERE  op.id_compte = co.id_compte
        )                               AS nb_operations
    FROM  Compte co
    INNER JOIN Client cl ON co.id_client = cl.id_client
    INNER JOIN Agence a  ON co.id_agence = a.id_agence
    WHERE co.numero_compte = @numero_compte;
END;
GO

CREATE OR ALTER TRIGGER TRG_EmpecherSoldeNegatif
ON Compte
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted WHERE solde < 0
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('ERREUR : Opération refusée — le solde ne peut pas devenir négatif.', 16, 1);
        RETURN;
    END;
END;
GO

CREATE OR ALTER TRIGGER TRG_AuditOperation
ON Operation
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Audit_Operations (
        id_operation, id_compte, type_operation, montant,
        solde_avant, solde_apres
    )
    SELECT
        i.id_operation,
        i.id_compte,
        i.type_operation,
        i.montant,
        -- Solde avant = solde actuel ± montant (sens inverse de l'opération)
        CASE
            WHEN i.type_operation IN ('Dépôt', 'Virement entrant')
                THEN c.solde - i.montant
            WHEN i.type_operation IN ('Retrait', 'Virement sortant')
                THEN c.solde + i.montant
            ELSE c.solde
        END AS solde_avant,
        c.solde AS solde_apres
    FROM inserted i
    INNER JOIN Compte c ON i.id_compte = c.id_compte;
END;
GO

CREATE OR ALTER TRIGGER TRG_EmpecherSuppressionClient
ON Client
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM   deleted d
        INNER JOIN Compte co ON d.id_client = co.id_client
    )
    BEGIN
        RAISERROR('ERREUR : Impossible de supprimer un client possédant encore des comptes actifs.', 16, 1);
        RETURN;
    END;

    -- Si aucun compte associé, la suppression est autorisée
    DELETE FROM Client
    WHERE id_client IN (SELECT id_client FROM deleted);
END;
GO

CREATE OR ALTER VIEW V_CompteClients AS
SELECT
    co.numero_compte,
    co.type_compte,
    CAST(co.solde AS BIGINT)    AS solde_FCFA,
    co.statut,
    co.date_ouverture,
    cl.nom                      AS nom_client,
    cl.prenom                   AS prenom_client,
    cl.telephone                AS tel_client,
    a.nom_agence,
    a.ville                     AS ville_agence
FROM Compte co
INNER JOIN Client cl ON co.id_client = cl.id_client
INNER JOIN Agence a  ON co.id_agence = a.id_agence;
GO

CREATE OR ALTER VIEW V_HistoriqueOperations AS
SELECT
    op.id_operation,
    op.type_operation,
    CAST(op.montant AS BIGINT)      AS montant_FCFA,
    op.date_operation,
    op.description,
    co.numero_compte,
    co.type_compte,
    cl.nom                          AS nom_client,
    cl.prenom                       AS prenom_client,
    a.nom_agence
FROM Operation op
INNER JOIN Compte  co ON op.id_compte  = co.id_compte
INNER JOIN Client  cl ON co.id_client  = cl.id_client
INNER JOIN Agence  a  ON co.id_agence  = a.id_agence;
GO

CREATE OR ALTER VIEW V_SoldesParAgence AS
SELECT
    a.id_agence,
    a.nom_agence,
    a.ville,
    COUNT(co.id_compte)             AS nb_comptes,
    CAST(SUM(co.solde) AS BIGINT)   AS total_soldes_FCFA,
    CAST(AVG(co.solde) AS BIGINT)   AS solde_moyen_FCFA,
    COUNT(e.id_employe)             AS nb_employes
FROM Agence a
LEFT JOIN Compte  co ON a.id_agence = co.id_agence
LEFT JOIN Employe e  ON a.id_agence = e.id_agence
GROUP BY a.id_agence, a.nom_agence, a.ville;
GO

-- Utilisation : SELECT * FROM V_SoldesParAgence ORDER BY total_soldes_FCFA DESC;

-- V4 : Clients VIP (solde total > 10 000 000 FCFA)

CREATE OR ALTER VIEW V_ClientsVIP AS
SELECT
    cl.id_client,
    cl.nom,
    cl.prenom,
    cl.telephone,
    cl.email,
    cl.ville,
    COUNT(co.id_compte)             AS nb_comptes,
    CAST(SUM(co.solde) AS BIGINT)   AS solde_total_FCFA
FROM Client cl
INNER JOIN Compte co ON cl.id_client = co.id_client
GROUP BY cl.id_client, cl.nom, cl.prenom, cl.telephone, cl.email, cl.ville
HAVING SUM(co.solde) > 10000000;
GO

-- Utilisation : SELECT * FROM V_ClientsVIP ORDER BY solde_total_FCFA DESC;
