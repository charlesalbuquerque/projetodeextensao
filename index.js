const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Rota de teste para ver se o servidor está funcionando
app.get('/', (req, res) => {
  res.send('🐾 Sistema de Resgate Animal: API Online!');
});

// Rota para CRIAR um animal ("Estoque")
app.post('/animais', async (req, res) => {
  try {
    const { nome, especie, situacao, localizacao, descricao } = req.body;
    
    const novoAnimal = await prisma.animal.create({
      data: {
        nome,
        especie,
        situacao,
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

// Rota para LISTAR todos os animais
app.get('/animais', async (req, res) => {
  const animais = await prisma.animal.findMany();
  res.json(animais);
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando em: http://localhost:${PORT}`);
});