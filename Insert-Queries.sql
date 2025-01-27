-- Populando Cliente
INSERT INTO Cliente (Nome, email) VALUES
('João Silva', 'joao@email.com'),
('Maria Santos', 'maria@email.com'),
('Pedro Oliveira', 'pedro@email.com'),
('Ana Costa', 'ana@email.com'),
('Carlos Souza', 'carlos@email.com');

-- Populando Equipe
INSERT INTO Equipe (QuantidadeMecanicos) VALUES
(3),
(4),
(2),
(5);

-- Populando Mecanico
INSERT INTO Mecanico (Nome, Endereco, Especialidade, Equipe_idEquipe) VALUES
('José Mecânico', 'Rua A, 123', 'Motor', 1),
('Roberto Silva', 'Rua B, 456', 'Elétrica', 1),
('Paulo Santos', 'Rua C, 789', 'Suspensão', 2),
('Antonio Costa', 'Rua D, 321', 'Freios', 2),
('Lucas Oliveira', 'Rua E, 654', 'Motor', 3),
('Fernando Souza', 'Rua F, 987', 'Elétrica', 4);

-- Populando Veiculo
INSERT INTO Veiculo (Cliente_idCliente, Equipe_idEquipe) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4);

-- Populando Servico
INSERT INTO Servico (idServico, Equipe_idEquipe, Cliente_idCliente, Status) VALUES
(1, 1, 1, 'em andamento'),
(2, 1, 2, 'finalizado'),
(3, 2, 3, 'em espera'),
(4, 3, 4, 'em andamento'),
(5, 4, 5, 'finalizado');

-- Populando OrdemServico
INSERT INTO OrdemServico (idOrdemServico, DataEmissao, Valor, Status, DataConclusao) VALUES
(1, '2024-01-15', '500.00', 'Em Andamento', NULL),
(2, '2024-01-16', '750.00', 'Concluído', '2024-01-20'),
(3, '2024-01-17', '300.00', 'Em Espera', NULL),
(4, '2024-01-18', '1200.00', 'Em Andamento', NULL),
(5, '2024-01-19', '900.00', 'Concluído', '2024-01-23');

-- Populando ValorServico
INSERT INTO ValorServico (Servico_idServico, Servico_Equipe_idEquipe, OrdemServico_idOrdemServico, Valor) VALUES
(1, 1, 1, 500.00),
(2, 1, 2, 750.00),
(3, 2, 3, 300.00),
(4, 3, 4, 1200.00),
(5, 4, 5, 900.00);

-- Populando Peca
INSERT INTO Peca (Valor) VALUES
(150.00),
(200.00),
(80.00),
(300.00),
(450.00);

-- Populando PecaEmOrdemServico
INSERT INTO PecaEmOrdemServico (Peca_idPeca, OrdemServico_idOrdemServico, Quantidade) VALUES
(1, 1, 2),
(2, 1, 1),
(3, 2, 3),
(4, 3, 1),
(5, 4, 2);

-- Queries complexas com suas respectivas perguntas:

-- 1. Qual é o valor total gasto em serviços por cada cliente, ordenado do maior para o menor valor?
SELECT 
    c.Nome,
    c.email,
    ROUND(SUM(vs.Valor), 2) as Valor_Total
FROM Cliente c
JOIN Servico s ON c.idCliente = s.Cliente_idCliente
JOIN ValorServico vs ON s.idServico = vs.Servico_idServico
GROUP BY c.idCliente, c.Nome, c.email
ORDER BY Valor_Total DESC;

-- 2. Quais equipes têm mais de 3 mecânicos e qual o valor médio dos serviços realizados por elas (em ordem decrescente por valor de serviço)?
SELECT 
    e.idEquipe,
    e.QuantidadeMecanicos,
    ROUND(AVG(vs.Valor), 2) as Media_Valor_Servicos
FROM Equipe e
JOIN ValorServico vs ON e.idEquipe = vs.Servico_Equipe_idEquipe
WHERE e.QuantidadeMecanicos > 3
GROUP BY e.idEquipe, e.QuantidadeMecanicos
ORDER BY Media_Valor_Servicos DESC;


-- 3. Quais clientes têm serviços em andamento e qual o valor total das peças utilizadas?
SELECT 
    c.Nome,
    s.Status,
    SUM(p.Valor * pos.Quantidade) as Valor_Total_Pecas
FROM Cliente c
JOIN Servico s ON c.idCliente = s.Cliente_idCliente
JOIN OrdemServico os ON s.idServico = os.idOrdemServico
JOIN PecaEmOrdemServico pos ON os.idOrdemServico = pos.OrdemServico_idOrdemServico
JOIN Peca p ON pos.Peca_idPeca = p.idPeca
WHERE s.Status = 'em andamento'
GROUP BY c.Nome, s.Status;

-- 4. Qual é a especialidade mais comum entre os mecânicos e quantos mecânicos há em cada especialidade?
SELECT 
    Especialidade,
    COUNT(*) as Quantidade,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mecanico), 2) as Porcentagem
FROM Mecanico
GROUP BY Especialidade
ORDER BY Quantidade DESC;

-- 5. Quais ordens de serviço têm valor total (serviço + peças) superior à média geral?
WITH ValorTotalOS AS (
    SELECT 
        os.idOrdemServico,
        vs.Valor as Valor_Servico,
        SUM(p.Valor * pos.Quantidade) as Valor_Pecas,
        vs.Valor + SUM(p.Valor * pos.Quantidade) as Valor_Total
    FROM OrdemServico os
    JOIN ValorServico vs ON os.idOrdemServico = vs.OrdemServico_idOrdemServico
    JOIN PecaEmOrdemServico pos ON os.idOrdemServico = pos.OrdemServico_idOrdemServico
    JOIN Peca p ON pos.Peca_idPeca = p.idPeca
    GROUP BY os.idOrdemServico, vs.Valor
)
SELECT *
FROM ValorTotalOS
WHERE Valor_Total > (SELECT AVG(Valor_Total) FROM ValorTotalOS);


-- 6. Qual é a eficiência de cada equipe (relação entre serviços concluídos e total de serviços)?
SELECT 
    e.idEquipe,
    COUNT(s.idServico) as Total_Servicos,
    SUM(CASE WHEN s.Status = 'finalizado' THEN 1 ELSE 0 END) as Servicos_Concluidos,
    ROUND(SUM(CASE WHEN s.Status = 'finalizado' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.idServico), 2) as Eficiencia_Percentual
FROM Equipe e
LEFT JOIN Servico s ON e.idEquipe = s.Equipe_idEquipe
GROUP BY e.idEquipe
ORDER BY Eficiencia_Percentual DESC;

-- 7. Quais clientes gastaram mais que a média em serviços?
SELECT 
    c.Nome,
    ROUND(SUM(vs.Valor), 2) as Valor_Total
FROM Cliente c
JOIN Servico s ON c.idCliente = s.Cliente_idCliente
JOIN ValorServico vs ON s.idServico = vs.Servico_idServico
JOIN OrdemServico os ON vs.OrdemServico_idOrdemServico = os.idOrdemServico
GROUP BY c.idCliente, c.Nome
HAVING Valor_Total > (
    SELECT AVG(total_por_cliente)
    FROM (
        SELECT SUM(vs2.Valor) as total_por_cliente
        FROM Cliente c2
        JOIN Servico s2 ON c2.idCliente = s2.Cliente_idCliente
        JOIN ValorServico vs2 ON s2.idServico = vs2.Servico_idServico
        GROUP BY c2.idCliente
    ) as medias
);

-- 8. Qual é a distribuição de serviços por status e equipe?
SELECT 
    e.idEquipe,
    s.Status,
    COUNT(*) as Quantidade_Servicos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY e.idEquipe), 2) as Percentual_Por_Equipe
FROM Equipe e
LEFT JOIN Servico s ON e.idEquipe = s.Equipe_idEquipe
GROUP BY e.idEquipe, s.Status
ORDER BY e.idEquipe, s.Status;

-- 9. Quais mecânicos participaram de serviços com valor superior a R$ 1000?
SELECT DISTINCT
    m.Nome as Mecanico,
    m.Especialidade,
    vs.Valor as Valor_Servico
FROM Mecanico m
JOIN Equipe e ON m.Equipe_idEquipe = e.idEquipe
JOIN ValorServico vs ON e.idEquipe = vs.Servico_Equipe_idEquipe
WHERE vs.Valor > 1000
ORDER BY vs.Valor DESC;

-- 10. Qual é o ranking de clientes por fidelidade (quantidade de serviços requisitados)?
SELECT 
    c.Nome,
    COUNT(s.idServico) as Quantidade_Servicos,
    ROUND(SUM(vs.Valor), 2) as Valor_Total_Gasto,
    DENSE_RANK() OVER (ORDER BY COUNT(s.idServico) DESC) as Ranking_Fidelidade
FROM Cliente c
LEFT JOIN Servico s ON c.idCliente = s.Cliente_idCliente
LEFT JOIN ValorServico vs ON s.idServico = vs.Servico_idServico
GROUP BY c.idCliente, c.Nome
ORDER BY Ranking_Fidelidade;