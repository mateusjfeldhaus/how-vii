import express from "express";
import dotenv from "dotenv";
import mysql from "mysql2/promise";

dotenv.config();

const app = express();
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "12345678",
  database: process.env.DB_NAME || "how_vii",
});

app.get("/", (_req, res) => {
  res.json({ ok: true, service: "how-vii-api" });
});

// ROTA PARA CONSULTAR A VIEW

app.get("/pagamentos", async (_req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT id_venda,
              data_do_pagamento,
              valor_do_pagamento,
              codigo_imovel,
              descricao_imovel,
              cidade_imovel,
              tipo_imovel
       FROM vw_pagamentos_denormalizados
       ORDER BY data_do_pagamento, id_venda`
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao consultar pagamentos." });
  }
});

app.get("/totais", async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT imovel_id, valor_do_pagamento
      FROM pagamento
    `);

    const totais = rows.reduce((acc, row) => {
      const id = row.imovel_id;
      const valor = Number(row.valor_do_pagamento);
      if (!acc[id]) {
        acc[id] = 0;
      }
      acc[id] += valor;
      return acc;
    }, {});

    res.json(totais);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao calcular totais." });
  }
});

app.get("/totais-mensais", async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT data_do_pagamento, valor_do_pagamento
      FROM pagamento
    `);

    const totaisMensais = rows.reduce((acc, row) => {
      const data = new Date(row.data_do_pagamento);

      const mes = String(data.getMonth() + 1).padStart(2, "0");
      const ano = data.getFullYear();
      const chave = `${mes}/${ano}`;

      if (!acc[chave]) {
        acc[chave] = 0;
      }
      acc[chave] += Number(row.valor_do_pagamento);
      return acc;
    }, {});

    const resultado = Object.entries(totaisMensais)
      .sort((a, b) => {
        const [ma, aa] = a[0].split("/").map(Number);
        const [mb, ab] = b[0].split("/").map(Number);
        return aa === ab ? ma - mb : aa - ab;
      })
      .map(([periodo, total]) => ({ periodo, total }));

    res.json(resultado);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao calcular totais mensais." });
  }
});

app.get("/tipos-percentual", async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT t.nome AS tipo, COUNT(*) AS quantidade
      FROM pagamento p
      JOIN imovel i       ON i.id = p.imovel_id
      JOIN tipo_imovel t  ON t.id = i.tipo_imovel_id
      GROUP BY t.nome
      ORDER BY t.nome
    `);

    const total = rows.reduce((sum, r) => sum + Number(r.quantidade), 0);

    if (total === 0) {
      return res.json([]);
    }

    const resultado = rows.map(r => ({
      tipo: r.tipo,
      quantidade: Number(r.quantidade),
      percentual: Number(((Number(r.quantidade) / total) * 100).toFixed(2)) // ex.: 33.33
    }));

    res.json({
      total_vendas: total,
      distribuicao: resultado
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao calcular percentuais por tipo." });
  }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});