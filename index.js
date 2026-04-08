const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt'); 
const jwt = require('jsonwebtoken'); 

const app = express();
app.use(cors());
app.use(express.json());

// Em um projeto real, essa chave ficaria protegida no .env
const SECRET_KEY = "sua_chave_secreta_super_segura";

// ROTAS DE TESTE E STATUS
app.get('/', (req, res) => {
  res.send('🐾 Sistema de Resgate Animal: API Online!');
});

// ROTAS DE AUTENTICAÇÃO

// Cadastro de Usuário
app.post('/auth/register', async (req, res) => {
  try {
    const { nome, email, senha } = req.body;
    const hashedPassword = await bcrypt.hash(senha, 10);

    const user = await prisma.user.create({
      data: {
        nome,
        email,
        senha: hashedPassword,
        role: "USER"
      }
    });

    res.status(201).json({ message: "Usuário criado com sucesso!" });
  } catch (error) {
    res.status(400).json({ error: "E-mail já cadastrado ou dados inválidos." });
  }
});

// Login
app.post('/auth/login', async (req, res) => {
  try {
    const { email, senha } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) return res.status(401).json({ error: "Credenciais inválidas." });

    const passwordMatch = await bcrypt.compare(senha, user.senha);
    if (!passwordMatch) return res.status(401).json({ error: "Credenciais inválidas." });

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      SECRET_KEY,
      { expiresIn: '24h' }
    );

    res.json({
      message: "Bem-vindo(a)!",
      token,
      user: { nome: user.nome, email: user.email, role: user.role }
    });
  } catch (error) {
    res.status(500).json({ error: "Erro interno no servidor." });
  }
});

// ROTAS DE ANIMAIS (ESTOQUE)

app.post('/animais', async (req, res) => {
  try {
    const { nome, especie, status, localizacao, descricao } = req.body;
    
    const novoAnimal = await prisma.animal.create({
      data: {
        nome,
        especie,
        status,
        localizacao,
        descricao
      }
    });
    
    res.status(201).json(novoAnimal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao cadastrar animal.' });
  }
});

app.get('/animais', async (req, res) => {
  const animais = await prisma.animal.findMany();
  res.json(animais);
});

// INICIALIZAÇÃO DO SERVIDOR
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando em: http://localhost:${PORT}`);
});

// ROTAS FINANCEIRAS (FLUXO DE CAIXA)

// 1. Registrar uma Doação (Entrada)
app.post('/financeiro/doacao', async (req, res) => {
  try {
    const { valor, doador, animalId } = req.body;
    const doacao = await prisma.donation.create({
      data: { valor, doador, animalId }
    });
    res.status(201).json(doacao);
  } catch (error) {
    res.status(400).json({ error: "Erro ao registrar doação." });
  }
});

// 2. Registrar um Gasto (Saída)
app.post('/financeiro/gasto', async (req, res) => {
  try {
    const { valor, descricao, categoria } = req.body;
    const gasto = await prisma.expense.create({
      data: { valor, descricao, categoria }
    });
    res.status(201).json(gasto);
  } catch (error) {
    res.status(400).json({ error: "Erro ao registrar gasto." });
  }
});

// 3. Resumo Financeiro
app.get('/financeiro/resumo', async (req, res) => {
  try {
    // Soma todas as doações
    const totalDoacoes = await prisma.donation.aggregate({
      _sum: { valor: true }
    });

    // Soma todos os gastos
    const totalGastos = await prisma.expense.aggregate({
      _sum: { valor: true }
    });

    const doacoes = totalDoacoes._sum.valor || 0;
    const gastos = totalGastos._sum.valor || 0;
    const saldo = doacoes - gastos;

    res.json({
      total_recebido: doacoes,
      total_gasto: gastos,
      lucro_prejuizo: saldo
    });
  } catch (error) {
    res.status(500).json({ error: "Erro ao gerar resumo financeiro." });
  }
});

// Middleware para verificar se o usuário está logado
const verificarToken = (req, res, next) => {
  const token = req.headers['authorization'];

  if (!token) return res.status(403).json({ error: "Nenhum token fornecido." });

  const limpo = token.split(' ')[1] || token;

  jwt.verify(limpo, SECRET_KEY, (err, decoded) => {
    if (err) return res.status(401).json({ error: "Token inválido ou expirado." });
    
    // Salva o ID do usuário na requisição para uso futuro
    req.userId = decoded.userId;
    next();
  });
};

app.post('/animais', verificarToken, async (req, res) => {
  try {
    const { nome, especie, status, localizacao, descricao } = req.body;
    
    const novoAnimal = await prisma.animal.create({
      data: {
        nome,
        especie,
        status,
        localizacao,
        descricao
      }
    });
    
    res.status(201).json(novoAnimal);
  } catch (error) {
    res.status(500).json({ error: 'Erro ao cadastrar animal.' });
  }
});

// Rota para mudar status (Tratamento -> Adoção)
app.patch('/animais/:id/status', verificarToken, async (req, res) => {
  const { id } = req.params;
  const { status } = req.body; 

  try {
    const atualizado = await prisma.animal.update({
      where: { id: parseInt(id) },
      data: { status }
    });
    res.json(atualizado);
  } catch (error) {
    res.status(400).json({ error: "Erro ao atualizar status." });
  }
});

// Alterar o status de um animal (Ex: de "Tratamento" para "Adotado")
app.patch('/animais/:id/status', verificarToken, async (req, res) => {
  const { id } = req.params; // Pega o ID da URL
  const { status } = req.body; // Pega o novo status do corpo da requisição

  try {
    const animalAtualizado = await prisma.animal.update({
      where: { 
        id: Number(id) // O Prisma precisa que o ID seja um número
      },
      data: { 
        status : status 
      }
    });

    res.json({
      message: "Status atualizado com sucesso!",
      animal: animalAtualizado
    });
  } catch (error) {
    res.status(400).json({ error: "Não foi possível atualizar. Verifique se o ID do animal está correto." });
  }
});