/* 1. Liste todos os voos realizados... 
   Para listar os voos realizados, fiz um JOIN entre a tabela de voos e as tabelas de aeronave. 
   Usei o ID da aeronave para fazer essa ligação e trazer o nome do modelo. 
   No final, ordenei pela data de partida de forma decrescente (DESC) para que os voos mais 
   recentes apareçam primeiro no resultado.
*/
SELECT
    v.ID_VOO,
    v.NUMERO_VOO,
    v.PARTIDA_REAL,
    v.CHEGADA_REAL,
    v.ID_AERONAVE,
    at.NOME AS TIPO_AERONAVE
FROM VOO v
JOIN AERONAVE a ON v.ID_AERONAVE = a.ID_AERONAVE
JOIN AERONAVE_TIPO at ON a.ID_AERONAVE_TIPO = at.ID_AERONAVE_TIPO
ORDER BY v.PARTIDA_REAL DESC;


/* 2. Liste apenas voos cuja origem e destino sejam aeroportos diferentes...
   Aqui eu precisei fazer o JOIN com a tabela AEROPORTO duas vezes, uma para a origem (chamada de 'ao') 
   e outra para o destino ('ad'). Isso permite mostrar os nomes dos dois aeroportos na mesma linha. 
   Usei o WHERE com '<>' para garantir que a origem seja diferente do destino, deixando de fora voos 
   que voltam para o mesmo lugar.
*/
SELECT
    vp.NUMERO_VOO,
    ao.IATA AS IATA_ORIGEM,
    ao.NOME AS AEROPORTO_ORIGEM,
    ad.IATA AS IATA_DESTINO,
    ad.NOME AS AEROPORTO_DESTINO
FROM VOO_PROGRAMACAO vp
JOIN AEROPORTO ao ON vp.ID_AEROPORTO_ORIGEM = ao.ID_AEROPORTO
JOIN AEROPORTO ad ON vp.ID_AEROPORTO_DESTINO = ad.ID_AEROPORTO
WHERE vp.ID_AEROPORTO_ORIGEM <> vp.ID_AEROPORTO_DESTINO;


/* 3. Mostre todas as reservas apresentando o identificador da reserva, nome completo...
   Nessa consulta, juntei as tabelas de RESERVA, PASSAGEIRO e VOO para pegar os detalhes da compra 
   e do cliente. Usei o '||' para juntar o nome e o sobrenome em uma coluna só, o que deixa o 
   resultado mais limpo de ler. Por fim, ordenei tudo pelo nome do passageiro e depois pelo 
   número do voo para ficar bem organizado.
*/
SELECT
    r.ID_RESERVA,
    p.NOME || ' ' || p.SOBRENOME AS NOME_COMPLETO,
    pd.CIDADE,
    pd.PAIS,
    v.NUMERO_VOO,
    r.ASSENTO,
    r.PRECO
FROM RESERVA r
JOIN PASSAGEIRO p ON r.ID_PASSAGEIRO = p.ID_PASSAGEIRO
JOIN PASSAGEIRO_DETALHES pd ON p.ID_PASSAGEIRO = pd.ID_PASSAGEIRO
JOIN VOO v ON r.ID_VOO = v.ID_VOO
ORDER BY p.NOME, v.NUMERO_VOO;


/* 4. Apresente, para cada companhia aérea, seu nome e o valor total obtido...
   Para calcular o valor total, fui ligando as tabelas desde COMPANHIA_AEREA até chegar na RESERVA. 
   Agrupei os dados pelo nome da companhia usando o GROUP BY e usei a função SUM para somar os 
   preços pagos e a função COUNT para contar quantas reservas cada uma teve. 
   Ordenei do maior valor para o menor (DESC).
*/
SELECT
    ca.NOME_COMPANHIA,
    SUM(r.PRECO) AS VALOR_TOTAL_ARRECADADO,
    COUNT(r.ID_RESERVA) AS TOTAL_RESERVAS
FROM COMPANHIA_AEREA ca
JOIN VOO_PROGRAMACAO vp ON ca.ID_COMPANHIA = vp.ID_COMPANHIA
JOIN VOO v ON vp.NUMERO_VOO = v.NUMERO_VOO
JOIN RESERVA r ON v.ID_VOO = r.ID_VOO
GROUP BY ca.ID_COMPANHIA, ca.NOME_COMPANHIA
ORDER BY VALOR_TOTAL_ARRECADADO DESC;


/* 5. Liste o sobrenome e a cidade de residência dos passageiros que possuem reserva para GRU...
   O objetivo aqui era achar quem vai para Guarulhos, então fiz os JOINs até chegar no aeroporto 
   de destino e filtrei por IATA = 'GRU'. Coloquei um DISTINCT logo no SELECT para o mesmo passageiro 
   não aparecer duplicado caso tenha comprado mais de uma coisa na reserva. Também usei a função TRUNC 
   na data de partida para mostrar só o dia, tirando a parte das horas.
*/
SELECT DISTINCT
    p.SOBRENOME,
    pd.CIDADE,
    vp.NUMERO_VOO,
    TRUNC(v.PARTIDA_REAL) AS DATA_PARTIDA,
    r.PRECO
FROM RESERVA r
JOIN PASSAGEIRO p ON r.ID_PASSAGEIRO = p.ID_PASSAGEIRO
JOIN PASSAGEIRO_DETALHES pd ON p.ID_PASSAGEIRO = pd.ID_PASSAGEIRO
JOIN VOO v ON r.ID_VOO = v.ID_VOO
JOIN VOO_PROGRAMACAO vp ON v.NUMERO_VOO = vp.NUMERO_VOO
JOIN AEROPORTO ad ON vp.ID_AEROPORTO_DESTINO = ad.ID_AEROPORTO
WHERE ad.IATA = 'GRU';


/* 6. Para cada ocorrência de voo, apresente o número do voo, nome da companhia, percentual de ocupação...
   Para ver o percentual de ocupação, fiz uma conta: dividi a quantidade de reservas pela capacidade 
   da aeronave e multipliquei por 100, usando o ROUND para arredondar em duas casas decimais. 
   O HAVING com COUNT >= 1 foi colocado de propósito para mostrar só os voos que têm pelo menos uma 
   pessoa confirmada, ignorando aviões que estivessem vazios na base.
*/
SELECT
    v.NUMERO_VOO,
    ca.NOME_COMPANHIA,
    ao.NOME AS ORIGEM,
    ad.NOME AS DESTINO,
    a.CAPACIDADE,
    COUNT(r.ID_RESERVA) AS QTD_RESERVAS,
    ROUND((COUNT(r.ID_RESERVA) / a.CAPACIDADE) * 100, 2) AS PERCENTUAL_OCUPACAO,
    SUM(r.PRECO) AS VALOR_TOTAL_VOO
FROM VOO v
JOIN VOO_PROGRAMACAO vp ON v.NUMERO_VOO = vp.NUMERO_VOO
JOIN COMPANHIA_AEREA ca ON vp.ID_COMPANHIA = ca.ID_COMPANHIA
JOIN AEROPORTO ao ON vp.ID_AEROPORTO_ORIGEM = ao.ID_AEROPORTO
JOIN AEROPORTO ad ON vp.ID_AEROPORTO_DESTINO = ad.ID_AEROPORTO
JOIN AERONAVE a ON v.ID_AERONAVE = a.ID_AERONAVE
JOIN RESERVA r ON v.ID_VOO = r.ID_VOO
GROUP BY
    v.ID_VOO,
    v.NUMERO_VOO,
    ca.NOME_COMPANHIA,
    ao.NOME,
    ad.NOME,
    a.CAPACIDADE
HAVING COUNT(r.ID_RESERVA) >= 1
ORDER BY PERCENTUAL_OCUPACAO DESC;


/* 7. Consulta Livre (1) baseada nas modificações da etapa A1.
   Esta foi uma das consultas extras que criei usando as tabelas novas do exercício A1. 
   A ideia foi relacionar as bagagens com os passageiros e o tipo de tarifa comprada. 
   Fiz isso para verificar facilmente o peso e o status da mala dependendo da classe que a 
   pessoa escolheu na viagem (Econômica, Executiva, etc.).
*/
SELECT
    b.BAGAGEM_ID,
    b.BAGAGEM_PESO,
    b.BAGAGEM_TIPO,
    b.BAGAGEM_STATUS,
    p.NOME || ' ' || p.SOBRENOME AS PASSAGEIRO,
    c.CLASSE_NOME,
    t.TARIFA_NOME
FROM BAGAGEM b
JOIN RESERVA r ON b.ID_RESERVA = r.ID_RESERVA
JOIN PASSAGEIRO p ON r.ID_PASSAGEIRO = p.ID_PASSAGEIRO
JOIN TARIFA t ON r.TARIFA_ID = t.TARIFA_ID
JOIN CLASSE c ON t.CLASSE_ID = c.CLASSE_ID;


/* 8. Consulta Livre (2) baseada nas modificações da etapa A1.
   Na minha segunda consulta extra, decidi focar em mostrar a quantidade de assentos reservados 
   separando por classe dentro de cada aeronave. Agrupei pelo ID do avião e pelo nome da classe, 
   contando os assentos na reserva. Achei útil para saber qual área do avião fica mais cheia 
   em cada voo.
*/
SELECT
    a.ID_AERONAVE,
    c.CLASSE_NOME,
    COUNT(r.ID_RESERVA) AS TOTAL_ASSENTOS_RESERVADOS
FROM ASSENTO ass
JOIN CLASSE c ON ass.CLASSE_ID = c.CLASSE_ID
JOIN AERONAVE a ON ass.AERONAVE_ID = a.ID_AERONAVE
JOIN RESERVA r
    ON ass.ASSENTO_NUMERO = r.ASSENTO_NUMERO
    AND a.ID_AERONAVE = r.ID_AERONAVE
GROUP BY a.ID_AERONAVE, c.CLASSE_NOME
ORDER BY a.ID_AERONAVE, TOTAL_ASSENTOS_RESERVADOS DESC;
