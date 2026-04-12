const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt'); 
const jwt = require('jsonwebtoken'); 

const app = express();
app.use(cors());
app.use(express.json());

const SECRET_KEY = "sua_chave_secreta_super_segura";

// --- MIDDLEWARES ---

const verificarToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(403).json({ error: "Nenhum token fornecido." });

  const token = authHeader.split(' ')[1] || authHeader;

  jwt.verify(token, SECRET_KEY, (err, decoded) => {
    if (err) return res.status(401).json({ error: "Token inválido ou expirado." });
    req.user = decoded; 
    next();
  });
};

const verificarAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'ADMIN') {
    next();
  } else {
    res.status(403).json({ error: "Acesso negado. Apenas administradores." });
  }
};

// --- ROTAS DE AUTENTICAÇÃO ---

app.post('/auth/register', async (req, res) => {
  try {
    const { nome, email, senha } = req.body;
    const hashedPassword = await bcrypt.hash(senha, 10);
    await prisma.user.create({
      data: { nome, email, senha: hashedPassword, role: "USER" }
    });
    res.status(201).json({ message: "Usuário criado com sucesso!" });
  } catch (error) {
    console.error("ERRO NO REGISTER:", error);
    res.status(400).json({ error: "Erro ao cadastrar usuário." });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { email, senha } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    
    if (!user || !(await bcrypt.compare(senha, user.senha))) {
      return res.status(401).json({ error: "Credenciais inválidas." });
    }

    const token = jwt.sign({ userId: user.id, role: user.role }, SECRET_KEY, { expiresIn: '24h' });

    res.json({ 
      token, 
      user: { id: user.id, nome: user.nome, email: user.email, role: user.role } 
    });
  } catch (error) {
    console.error("ERRO NO LOGIN:", error);
    res.status(500).json({ error: "Erro no servidor." });
  }
});

// --- ROTAS DE ANIMAIS ---

// Mural Público: Apenas aprovados
app.get('/animais', async (req, res) => {
  try {
    const animais = await prisma.animal.findMany({
      where: { isApproved: true }
    });
    res.json(animais);
  } catch (error) {
    console.error("ERRO NO GET /animais (Mural):", error);
    res.status(500).json({ error: "Erro ao carregar o mural de animais." });
  }
});

// Cadastro de Animal (Sempre entra como pendente)
app.post('/animais', verificarToken, async (req, res) => {
  try {
    const { nome, especie, status, localizacao, descricao } = req.body;
    const novoAnimal = await prisma.animal.create({
      data: {
        nome, especie, status, localizacao, descricao,
        isApproved: false 
      }
    });
    res.status(201).json(novoAnimal);
  } catch (error) {
    console.error("ERRO NO POST /animais (Cadastro):", error);
    res.status(500).json({ error: 'Erro ao cadastrar animal.' });
  }
});

// [ADMIN] Ver animais pendentes (Somente aqueles que NÃO foram adotados)
app.get('/admin/animais/pendentes', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const pendentes = await prisma.animal.findMany({
      where: { 
        isApproved: false,
        NOT: {
          status: "Adotado" // Impede que animais já adotados voltem para a fila de aprovação
        }
      }
    });
    res.json(pendentes);
  } catch (error) {
    console.error("ERRO NO GET /admin/pendentes:", error);
    res.status(500).json({ error: "Erro ao buscar animais pendentes." });
  }
});

// [ADMIN] Aprovar animal para o mural
app.put('/admin/animais/:id/aprovar', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.animal.update({
      where: { id: parseInt(id) },
      data: { isApproved: true, status: "Disponível" }
    });
    res.json({ message: "Animal aprovado para o mural!" });
  } catch (error) {
    console.error("ERRO NO PUT /aprovar:", error);
    res.status(400).json({ error: "Erro ao aprovar animal." });
  }
});

// --- ROTAS DE ADOÇÃO (CANDIDATURAS) ---

app.post('/adocoes/candidatar', verificarToken, async (req, res) => {
  try {
    const { animalId, info } = req.body;
    const candidatura = await prisma.adoptionApplication.create({
      data: {
        animalId: parseInt(animalId),
        userId: req.user.userId,
        info: info,
        status: "PENDENTE"
      }
    });
    res.status(201).json(candidatura);
  } catch (error) {
    console.error("ERRO NO POST /candidatar:", error);
    res.status(400).json({ error: "Erro ao enviar candidatura." });
  }
});

// [ADMIN] Ver lista de candidaturas (Apenas PENDENTES)
app.get('/admin/candidaturas', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const candidaturas = await prisma.adoptionApplication.findMany({
      where: { status: "PENDENTE" },
      include: {
        animal: true,
        user: { select: { nome: true, email: true } }
      }
    });
    res.json(candidaturas);
  } catch (error) {
    console.error("ERRO NO GET /admin/candidaturas:", error);
    res.status(500).json({ error: "Erro ao buscar candidaturas." });
  }
});

// [ADMIN] Aprovar ou Rejeitar candidatura
app.put('/admin/candidaturas/:id', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // "APROVADA" ou "REJEITADA"
    
    // 1. Atualiza a candidatura
    const candidatura = await prisma.adoptionApplication.update({
      where: { id: parseInt(id) },
      data: { status: status }
    });
    
    // 2. Se aprovada, o animal sai do mural e status vira "Adotado"
    if (status === "APROVADA") {
      await prisma.animal.update({
        where: { id: candidatura.animalId },
        data: { 
          isApproved: false, 
          status: "Adotado" 
        }
      });
    }
    
    res.json({ message: `Candidatura ${status.toLowerCase()} com sucesso.` });
  } catch (error) {
    console.error("ERRO NO PUT /admin/candidaturas:", error);
    res.status(400).json({ error: "Erro ao processar candidatura." });
  }
});

// --- ROTAS FINANCEIRAS ---

app.post('/financeiro/doacao', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { valor, doador, animalId } = req.body;
    const doacao = await prisma.donation.create({ 
      data: { valor: parseFloat(valor), doador, animalId } 
    });
    res.status(201).json(doacao);
  } catch (error) {
    console.error("ERRO NO POST /financeiro/doacao:", error);
    res.status(400).json({ error: "Erro ao registrar doação." });
  }
});

app.get('/financeiro/doacoes', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const doacoes = await prisma.donation.findMany({ orderBy: { data: 'desc' } });
    res.json(doacoes);
  } catch (error) {
    console.error("ERRO NO GET /financeiro/doacoes:", error);
    res.status(500).json({ error: "Erro ao buscar doações." });
  }
});

app.get('/financeiro/resumo', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const totalDoacoes = await prisma.donation.aggregate({ _sum: { valor: true } });
    const totalGastos = await prisma.expense.aggregate({ _sum: { valor: true } });
    const saldo = (totalDoacoes._sum.valor || 0) - (totalGastos._sum.valor || 0);
    res.json({ 
      total_recebido: totalDoacoes._sum.valor || 0, 
      total_gasto: totalGastos._sum.valor || 0, 
      saldo 
    });
  } catch (error) {
    console.error("ERRO NO GET /financeiro/resumo:", error);
    res.status(500).json({ error: "Erro ao gerar resumo." });
  }
});

app.post('/financeiro/despesa', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { valor, descricao, categoria } = req.body;
    const despesa = await prisma.expense.create({
      data: { valor: parseFloat(valor), descricao, categoria }
    });
    res.status(201).json(despesa);
  } catch (error) {
    console.error("ERRO NO POST /financeiro/despesa:", error);
    res.status(400).json({ error: "Erro ao registrar despesa." });
  }
});

app.get('/financeiro/despesas', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const despesas = await prisma.expense.findMany({ orderBy: { data: 'desc' } });
    res.json(despesas);
  } catch (error) {
    console.error("ERRO NO GET /financeiro/despesas:", error);
    res.status(500).json({ error: "Erro ao buscar despesas." });
  }
});