CREATE DATABASE Oficina;
use oficina;

-- Create Cliente table
CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(45),
    email VARCHAR(45)
);

-- Create Equipe table
CREATE TABLE Equipe (
    idEquipe INT PRIMARY KEY auto_increment,
    QuantidadeMecanicos INT
);

-- Create Mecanico table
CREATE TABLE Mecanico (
    idMecanico INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(45),
    Endereco VARCHAR(45),
    Especialidade VARCHAR(45),
    Equipe_idEquipe INT,
    FOREIGN KEY (Equipe_idEquipe) REFERENCES Equipe(idEquipe)
);

-- Create Veiculo table
CREATE TABLE Veiculo (
    idVeiculo INT PRIMARY KEY AUTO_INCREMENT,
    Cliente_idCliente INT,
    Equipe_idEquipe INT,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (Equipe_idEquipe) REFERENCES Equipe(idEquipe)
);

-- Create Servico table
CREATE TABLE Servico (
    idServico INT PRIMARY KEY,
    Equipe_idEquipe INT,
    Cliente_idCliente INT,
    Status ENUM('em espera', 'em andamento' ,'finalizado') DEFAULT 'finalizado',
    FOREIGN KEY (Equipe_idEquipe) REFERENCES Equipe(idEquipe),
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

-- Create OrdemServico table
CREATE TABLE OrdemServico (
    idOrdemServico INT PRIMARY KEY,
    DataEmissao VARCHAR(45),
    Valor VARCHAR(45),
    Status VARCHAR(45),
    DataConclusao VARCHAR(45)
);

-- Create ValorServico table
CREATE TABLE ValorServico (
    Servico_idServico INT,
    Servico_Equipe_idEquipe INT,
    OrdemServico_idOrdemServico INT,
    Valor FLOAT,
    FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico),
    FOREIGN KEY (Servico_Equipe_idEquipe) REFERENCES Equipe(idEquipe),
    FOREIGN KEY (OrdemServico_idOrdemServico) REFERENCES OrdemServico(idOrdemServico)
);

-- Create Peca table
CREATE TABLE Peca (
    idPeca INT PRIMARY KEY AUTO_INCREMENT,
    Valor FLOAT
);

-- Create PecaEmOrdemServico table
CREATE TABLE PecaEmOrdemServico (
    Peca_idPeca INT,
    OrdemServico_idOrdemServico INT,
    Quantidade INT,
    FOREIGN KEY (Peca_idPeca) REFERENCES Peca(idPeca),
    FOREIGN KEY (OrdemServico_idOrdemServico) REFERENCES OrdemServico(idOrdemServico)
);