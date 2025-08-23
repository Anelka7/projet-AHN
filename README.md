# projet-AHN

##  le schéma SQL

```sql
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
```
## Implémentation complète de l'application (Final.java)

```java
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class ApplicationParrainage extends JFrame {
    private JTable tableParrains, tableFilleuls, tableAssignations;
    private JButton btnAssigner, btnAfficher;
    private Connection connection;
    
    public ApplicationParrainage() {
        super("Système de Parrainage");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(1000, 700);
        setLocationRelativeTo(null);
        
        // Initialisation de la base de données
        initDatabase();
        
        // Création des composants
        JTabbedPane onglets = new JTabbedPane();
        
        // Panel pour l'affichage des données
        JPanel panelAffichage = new JPanel(new BorderLayout());
        tableParrains = new JTable();
        tableFilleuls = new JTable();
        tableAssignations = new JTable();
        
        // Panel pour les boutons
        JPanel panelBoutons = new JPanel();
        btnAssigner = new JButton("Attribuer aléatoirement");
        btnAfficher = new JButton("Afficher les assignations");
        panelBoutons.add(btnAssigner);
        panelBoutons.add(btnAfficher);
        
        // Ajout des onglets
        onglets.addTab("Parrains", new JScrollPane(tableParrains));
        onglets.addTab("Filleuls", new JScrollPane(tableFilleuls));
        onglets.addTab("Assignations", new JScrollPane(tableAssignations));
        
        // Ajout des composants au frame
        add(onglets, BorderLayout.CENTER);
        add(panelBoutons, BorderLayout.SOUTH);
        
        // Chargement des données
        chargerParrains();
        chargerFilleuls();
        
        // Gestion des événements
        btnAssigner.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                attribuerParrainsAleatoirement();
            }
        });
        
        btnAfficher.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                afficherAssignations();
            }
        });
    }
    
    private void initDatabase() {
        try {
            // Connexion à la base de données (à adapter selon votre configuration)
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/parrainage", "username", "password");
            
            // Création des tables si elles n'existent pas
            Statement stmt = connection.createStatement();
            
            String createParrainTable = "CREATE TABLE IF NOT EXISTS Parrain (" +
                "id INT PRIMARY KEY AUTO_INCREMENT, " +
                "nom VARCHAR(100) NOT NULL, " +
                "prenom VARCHAR(100) NOT NULL, " +
                "email VARCHAR(150), " +
                "telephone VARCHAR(20), " +
                "date_inscription DATE)";
            
            String createFilleulTable = "CREATE TABLE IF NOT EXISTS Filleul (" +
                "id INT PRIMARY KEY AUTO_INCREMENT, " +
                "nom VARCHAR(100) NOT NULL, " +
                "prenom VARCHAR(100) NOT NULL, " +
                "email VARCHAR(150), " +
                "telephone VARCHAR(20), " +
                "date_inscription DATE, " +
                "parrain_id INT, " +
                "FOREIGN KEY (parrain_id) REFERENCES Parrain(id))";
            
            stmt.execute(createParrainTable);
            stmt.execute(createFilleulTable);
            
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Erreur de connexion à la base de données: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void chargerParrains() {
        try {
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM Parrain");
            
            // Création du modèle de table
            DefaultTableModel model = new DefaultTableModel();
            model.addColumn("ID");
            model.addColumn("Nom");
            model.addColumn("Prénom");
            model.addColumn("Email");
            model.addColumn("Téléphone");
            model.addColumn("Date d'inscription");
            
            while (rs.next()) {
                model.addRow(new Object[]{
                    rs.getInt("id"),
                    rs.getString("nom"),
                    rs.getString("prenom"),
                    rs.getString("email"),
                    rs.getString("telephone"),
                    rs.getDate("date_inscription")
                });
            }
            
            tableParrains.setModel(model);
            
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Erreur lors du chargement des parrains: " + e.getMessage());
        }
    }
    
    private void chargerFilleuls() {
        try {
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM Filleul");
            
            // Création du modèle de table
            DefaultTableModel model = new DefaultTableModel();
            model.addColumn("ID");
            model.addColumn("Nom");
            model.addColumn("Prénom");
            model.addColumn("Email");
            model.addColumn("Téléphone");
            model.addColumn("Date d'inscription");
            model.addColumn("Parrain ID");
            
            while (rs.next()) {
                model.addRow(new Object[]{
                    rs.getInt("id"),
                    rs.getString("nom"),
                    rs.getString("prenom"),
                    rs.getString("email"),
                    rs.getString("telephone"),
                    rs.getDate("date_inscription"),
                    rs.getInt("parrain_id")
                });
            }
            
            tableFilleuls.setModel(model);
            
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Erreur lors du chargement des filleuls: " + e.getMessage());
        }
    }
    
    private void attribuerParrainsAleatoirement() {
        try {
            // Récupérer tous les IDs de parrains
            List<Integer> parrainIds = new ArrayList<>();
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT id FROM Parrain");
            
            while (rs.next()) {
                parrainIds.add(rs.getInt("id"));
            }
            
            // Récupérer tous les IDs de filleuls non assignés
            List<Integer> filleulIds = new ArrayList<>();
            rs = stmt.executeQuery("SELECT id FROM Filleul WHERE parrain_id IS NULL");
            
            while (rs.next()) {
                filleulIds.add(rs.getInt("id"));
            }
            
            // Mélanger aléatoirement la liste des parrains
            Collections.shuffle(parrainIds, new Random());
            
            // Vérifier qu'il y a assez de parrains
            if (parrainIds.size() < filleulIds.size()) {
                JOptionPane.showMessageDialog(this, 
                    "Attention: Il n'y a pas assez de parrains pour tous les filleuls!");
            }
            
            // Attribuer les parrains aux filleuls
            PreparedStatement pstmt = connection.prepareStatement(
                "UPDATE Filleul SET parrain_id = ? WHERE id = ?");
            
            for (int i = 0; i < filleulIds.size(); i++) {
                int parrainIndex = i % parrainIds.size(); // Réutiliser les parrains si nécessaire
                pstmt.setInt(1, parrainIds.get(parrainIndex));
                pstmt.setInt(2, filleulIds.get(i));
                pstmt.addBatch();
            }
            
            pstmt.executeBatch();
            
            JOptionPane.showMessageDialog(this, "Attribution des parrains terminée!");
            chargerFilleuls(); // Recharger les données
            
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Erreur lors de l'attribution: " + e.getMessage());
        }
    }
    
    private void afficherAssignations() {
        try {
            String query = "SELECT p.id as parrain_id, p.nom as parrain_nom, p.prenom as parrain_prenom, " +
                           "f.id as filleul_id, f.nom as filleul_nom, f.prenom as filleul_prenom " +
                           "FROM Parrain p " +
                           "JOIN Filleul f ON p.id = f.parrain_id " +
                           "ORDER BY p.nom, p.prenom";
            
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            
            // Création du modèle de table
            DefaultTableModel model = new DefaultTableModel();
            model.addColumn("ID Parrain");
            model.addColumn("Nom Parrain");
            model.addColumn("Prénom Parrain");
            model.addColumn("ID Filleul");
            model.addColumn("Nom Filleul");
            model.addColumn("Prénom Filleul");
            
            while (rs.next()) {
                model.addRow(new Object[]{
                    rs.getInt("parrain_id"),
                    rs.getString("parrain_nom"),
                    rs.getString("parrain_prenom"),
                    rs.getInt("filleul_id"),
                    rs.getString("filleul_nom"),
                    rs.getString("filleul_prenom")
                });
            }
            
            tableAssignations.setModel(model);
            
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Erreur lors du chargement des assignations: " + e.getMessage());
        }
    }
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                new ApplicationParrainage().setVisible(true);
            }
        });
    }
}  
```
## Instructions pour l'exécution
1. Assurez-vous d'avoir une base de données MySQL en cours d'exécution.
2. Créez une base de données nommée `parrainage`.
3. Remplacez `username` et `password` dans le code par vos identifi
ants MySQL.
4. Compilez et exécutez le programme Java.

# Explication du code
1. Initialisation de la base de données:
* Connexion à la base MySQL
* Création des tables si elles n'existent pas
2. Chargement des données:
* Récupération des parrains et filleuls depuis la base
*  Affichage dans des JTable
3. Attribution aléatoire:
* Récupération de tous les IDs de parrains et filleuls
* Mélange aléatoire de la liste des parrains

Attribution via des requêtes UPDATE batch

Affichage des assignations:

Jointure SQL entre les tables Parrain et Filleul

Affichage des noms grâce aux IDs