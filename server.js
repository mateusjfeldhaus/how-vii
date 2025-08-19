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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});