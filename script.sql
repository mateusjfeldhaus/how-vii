CREATE DATABASE IF NOT EXISTS how_vii;
USE how_vii;

DROP TABLE IF EXISTS pagamento;
DROP TABLE IF EXISTS imovel;
DROP TABLE IF EXISTS tipo_imovel;

CREATE TABLE tipo_imovel (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(60) NOT NULL,
  ativo          TINYINT(1) NOT NULL DEFAULT 1,
  criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_tipo_imovel__nome UNIQUE (nome)
);

CREATE TABLE imovel (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo           VARCHAR(32) NOT NULL,            
  descricao        TEXT NOT NULL,
  tipo_imovel_id   INT UNSIGNED NOT NULL,
  area_m2          INT UNSIGNED NULL,
  endereco         VARCHAR(255) NULL,
  cidade		   VARCHAR(100) NOT NULL,
  criado_em        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_imovel__codigo UNIQUE (codigo),
  CONSTRAINT fk_imovel__tipo
    FOREIGN KEY (tipo_imovel_id) REFERENCES tipo_imovel (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
 
CREATE INDEX idx_imovel__tipo ON imovel (tipo_imovel_id);

CREATE TABLE pagamento (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  imovel_id           BIGINT UNSIGNED NOT NULL,
  data_do_pagamento   DATE NOT NULL,
  valor_do_pagamento  DECIMAL(12,2) NOT NULL,
  criado_em           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pagamento__imovel
    FOREIGN KEY (imovel_id) REFERENCES imovel (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_pagamento__valor_pos CHECK (valor_do_pagamento > 0)
); 

CREATE INDEX idx_pagamento__imovel ON pagamento (imovel_id);
CREATE INDEX idx_pagamento__periodo ON pagamento (data_do_pagamento);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE pagamento;
TRUNCATE TABLE imovel;
TRUNCATE TABLE tipo_imovel;
SET FOREIGN_KEY_CHECKS = 1;


INSERT INTO tipo_imovel (nome, ativo) VALUES
  ('Apartamento', 1),
  ('Casa', 1),
  ('Sala Comercial', 1),
  ('Terreno', 1);
 
SELECT * FROM tipo_imovel;

INSERT INTO imovel (codigo, descricao, tipo_imovel_id, area_m2, endereco, cidade)
VALUES
  ('A100', 'Apto 2 quartos - condomínio',          1,  70,  'Rua Duque de Caxias, 123', 'Florianópolis'),
  ('C200', 'Casa geminada com pátio',              2, 120,  'Rua Barão de Mauá, 456', 'São José'),
  ('SC300','Sala comercial 45 m² - centro',        3,  45,  'Av. Central, 1000', 'Palhoça'),
  ('T400', 'Terreno 12x30 - bairro planejado',     4, 360,  'Rua das Figueiras, s/n', 'Biguaçu'),
  ('A110', 'Apto 1 quarto - próximo à UF',         1,  48,  'Rua Jornalista Tito Carvalho, 50', 'Florianópolis'),
  ('C210', 'Casa 3 dorm. - suíte e garagem',       2, 180,  'Rua das Palmeiras, 77', 'São José'),
  ('SC310','Sala comercial 65 m² - vista avenida', 3,  65,  'Av. Brasil, 250', 'Florianópolis'),
  ('A120', 'Apto 3 quartos - cobertura',           1, 110,  'Rua Bela Vista, 999', 'Palhoça');
 
 SELECT * FROM imovel;

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (1, '2025-03-05', 1500.00),
  (1, '2025-04-05', 1500.00),
  (1, '2025-05-05', 1500.00),
  (1, '2025-06-05', 1500.00),
  (1, '2025-07-05', 1500.00),
  (1, '2025-08-05', 1500.00);
 
 INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (2, '2025-03-10',  50000.00),
  (2, '2025-04-10',  50000.00),
  (2, '2025-05-10', 100000.00),
  (2, '2025-06-10',  75000.00),
  (2, '2025-07-10',  75000.00);
 
 INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (3, '2025-03-15', 2300.00),
  (3, '2025-04-15', 2300.00),
  (3, '2025-05-15', 2300.00),
  (3, '2025-06-15', 2300.00),
  (3, '2025-07-15', 2300.00),
  (3, '2025-08-15', 2300.00);

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (4, '2025-04-15',  20000.00),
  (4, '2025-07-01',  20000.00);

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (5, '2025-03-08', 1800.00),
  (5, '2025-04-08', 1800.00),
  (5, '2025-05-08', 1800.00),
  (5, '2025-06-08', 1800.00),
  (5, '2025-07-08', 1800.00);

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (6, '2025-05-20', 100000.00),
  (6, '2025-08-20', 100000.00);

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (7, '2025-06-25', 2900.00),
  (7, '2025-07-25', 2900.00),
  (7, '2025-08-25', 2900.00);

INSERT INTO pagamento (imovel_id, data_do_pagamento, valor_do_pagamento) VALUES
  (8, '2025-03-18', 1600.00);
 
 SELECT * FROM pagamento;

SELECT COUNT(*) AS qtde_pagamentos FROM pagamento;

SELECT DATE_FORMAT(data_do_pagamento, '%Y-%m') AS mes, COUNT(*) AS qtde
FROM pagamento
GROUP BY mes
ORDER BY mes;

CREATE OR REPLACE VIEW vw_pagamentos_denormalizados AS
SELECT
  p.id                        AS id_venda,
  p.data_do_pagamento,
  p.valor_do_pagamento,
  i.codigo                    AS codigo_imovel,
  i.descricao                 AS descricao_imovel,
  i.cidade                    AS cidade_imovel,
  t.nome                      AS tipo_imovel
FROM pagamento p
JOIN imovel i      ON i.id = p.imovel_id
JOIN tipo_imovel t ON t.id = i.tipo_imovel_id;


SELECT * FROM vw_pagamentos_denormalizados
ORDER BY data_do_pagamento, id_venda;