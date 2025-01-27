# Projeto Banco de Dados Oficina - Desafio DIO/Heineken

## Sobre o Projeto
Este projeto foi desenvolvido como parte do Desafio de Modelagem de Banco de Dados da DIO em parceria com a Heineken. O sistema implementa uma estrutura completa de banco de dados para uma oficina mecânica, incluindo modelo conceitual, esquema lógico e queries SQL complexas para análise de dados.

## Estrutura do Projeto

### Esquema do Banco de Dados
O banco de dados é composto pelas seguintes entidades principais:
- **Cliente**: Informações dos clientes
- **Equipe**: Dados das equipes de serviço
- **Mecânico**: Detalhes e especializações dos mecânicos
- **Veículo**: Informações dos veículos
- **Serviço**: Registros de serviços
- **OrdemServiço**: Ordens de serviço
- **Peça**: Inventário de peças
- **ValorServiço**: Precificação dos serviços
- **PeçaEmOrdemServiço**: Peças utilizadas nas ordens de serviço

### Relacionamentos entre Entidades
- Cada equipe pode ter múltiplos mecânicos
- Clientes podem ter múltiplos veículos e ordens de serviço
- Ordens de serviço podem incluir múltiplas peças e serviços
- Cada serviço é atribuído a uma equipe específica e um cliente

## Detalhes da Implementação

### Tecnologias Utilizadas
- MySQL Workbench para modelagem e gerenciamento do banco de dados
- SQL para criação do banco e consultas

### Criação do Banco de Dados
A implementação inclui:
1. Criação completa do esquema do banco
2. Relacionamentos e restrições entre tabelas
3. Definição dos tipos de dados
4. Implementação de chaves primárias e estrangeiras

### Dados de Exemplo
O banco inclui dados mockados para testes, cobrindo:
- Registros de clientes
- Composição das equipes
- Perfis dos mecânicos
- Informações de veículos
- Ordens de serviço e peças

## Consultas Complexas

O projeto inclui diversas consultas SQL complexas demonstrando:

1. **Consultas Simples com SELECT**
   - Recuperação básica de dados
   - Seleção e formatação de colunas

2. **Filtros com WHERE**
   - Filtragem condicional de dados
   - Combinação de múltiplas condições

3. **Atributos Derivados**
   - Campos calculados
   - Computações estatísticas

4. **Implementação de ORDER BY**
   - Ordenação de dados
   - Múltiplos critérios de ordenação

5. **Uso de HAVING**
   - Filtragem de grupos
   - Condições agregadas

6. **Junções Complexas de Tabelas**
   - Relacionamentos entre múltiplas tabelas
   - Subconsultas
   - Relacionamentos complexos de dados

## Consultas e Perguntas de Negócio Desenvolvidas

1. **Valor Total por Cliente**
```sql
SELECT 
    c.Nome,
    c.email,
    ROUND(SUM(vs.Valor), 2) as Valor_Total
FROM Cliente c
JOIN Servico s ON c.idCliente = s.Cliente_idCliente
JOIN ValorServico vs ON s.idServico = vs.Servico_idServico
GROUP BY c.idCliente, c.Nome, c.email
ORDER BY Valor_Total DESC;
```
Pergunta: Qual é o valor total gasto em serviços por cada cliente, ordenado do maior para o menor valor?

2. **Performance das Equipes**
```sql
SELECT 
    e.idEquipe,
    e.QuantidadeMecanicos,
    ROUND(AVG(vs.Valor), 2) as Media_Valor_Servicos
FROM Equipe e
JOIN ValorServico vs ON e.idEquipe = vs.Servico_Equipe_idEquipe
WHERE e.QuantidadeMecanicos > 3
GROUP BY e.idEquipe, e.QuantidadeMecanicos
HAVING AVG(vs.Valor) > 500;
```
Pergunta: Quais equipes têm mais de 3 mecânicos e qual o valor médio dos serviços realizados por elas?

3. **Análise de Serviços em Andamento**
```sql
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
```
Pergunta: Quais clientes têm serviços em andamento e qual o valor total das peças utilizadas?

4. **Distribuição de Especialidades**
```sql
SELECT 
    Especialidade,
    COUNT(*) as Quantidade,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mecanico), 2) as Porcentagem
FROM Mecanico
GROUP BY Especialidade
ORDER BY Quantidade DESC;
```
Pergunta: Qual é a especialidade mais comum entre os mecânicos e quantos mecânicos há em cada especialidade?

5. **Análise de Valores de Ordens de Serviço**
```sql
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
```
Pergunta: Quais ordens de serviço têm valor total (serviço + peças) superior à média geral?

6. **Eficiência das Equipes**
```sql
SELECT 
    e.idEquipe,
    COUNT(s.idServico) as Total_Servicos,
    SUM(CASE WHEN s.Status = 'finalizado' THEN 1 ELSE 0 END) as Servicos_Concluidos,
    ROUND(SUM(CASE WHEN s.Status = 'finalizado' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.idServico), 2) as Eficiencia_Percentual
FROM Equipe e
LEFT JOIN Servico s ON e.idEquipe = s.Equipe_idEquipe
GROUP BY e.idEquipe
ORDER BY Eficiencia_Percentual DESC;
```
Pergunta: Qual é a eficiência de cada equipe (relação entre serviços concluídos e total de serviços)?

7. **Análise de Gastos por Cliente**
```sql
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
```
Pergunta: Quais clientes gastaram mais que a média em serviços?

8. **Distribuição de Serviços**
```sql
SELECT 
    e.idEquipe,
    s.Status,
    COUNT(*) as Quantidade_Servicos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY e.idEquipe), 2) as Percentual_Por_Equipe
FROM Equipe e
LEFT JOIN Servico s ON e.idEquipe = s.Equipe_idEquipe
GROUP BY e.idEquipe, s.Status
ORDER BY e.idEquipe, s.Status;
```
Pergunta: Qual é a distribuição de serviços por status e equipe?

9. **Mecânicos em Serviços de Alto Valor**
```sql
SELECT DISTINCT
    m.Nome as Mecanico,
    m.Especialidade,
    vs.Valor as Valor_Servico
FROM Mecanico m
JOIN Equipe e ON m.Equipe_idEquipe = e.idEquipe
JOIN ValorServico vs ON e.idEquipe = vs.Servico_Equipe_idEquipe
WHERE vs.Valor > 1000
ORDER BY vs.Valor DESC;
```
Pergunta: Quais mecânicos participaram de serviços com valor superior a R$ 1000?

10. **Ranking de Fidelidade**
```sql
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
```
Pergunta: Qual é o ranking de clientes por fidelidade (quantidade de serviços)?

## Como Usar

1. Clone o repositório
2. Abra o MySQL Workbench
3. Execute o script de criação do esquema
4. Execute o script de população de dados
5. Teste as consultas fornecidas

