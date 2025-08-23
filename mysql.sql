CREATE TABLE Parrain (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    telephone VARCHAR(20),
    date_inscription DATE
);

CREATE TABLE Filleul (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    telephone VARCHAR(20),
    date_inscription DATE,
    parrain_id INT,
    FOREIGN KEY (parrain_id) REFERENCES Parrain(id)
);