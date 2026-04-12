# 🐾 Pet Rescue App - Sistema de Gestão de ONG

Este projeto de extensão é um sistema completo para gestão de resgates e adoções de animais. O ecossistema conta com um aplicativo móvel para usuários e administradores, integrado a um backend robusto para controle financeiro, de estoque (fornecedores) e aprovações.

---

## 🚀 Tecnologias Utilizadas

### **Backend**
* **Node.js** com **Express** (API REST)
* **Prisma ORM** (Gestão do Banco de Dados)
* **PostgreSQL** (Banco de Dados Relacional)
* **JWT & Bcrypt** (Segurança e Autenticação)

### **Frontend (Mobile)**
* **Flutter** (Framework Multiplataforma)
* **Shared Preferences** (Persistência de Token)
* **HTTP** (Consumo de API)

---

## 📁 Estrutura do Projeto

```text
/
├── backend/          # Servidor Node.js e arquivos do Prisma
└── frontend/         # Código fonte do App Flutter
```

---

## ⚙️ Como Rodar o Projeto

### **1. Configuração do Backend**
Navegue até a pasta `backend`:
1.  Instale as dependências:
    ```bash
    npm install
    ```
2.  Configure o arquivo `.env` com a sua URL do banco PostgreSQL:
    ```env
    DATABASE_URL="postgresql://usuario:senha@localhost:5432/pet_rescue"
    ```
3.  Sincronize o banco de dados e as migrações:
    ```bash
    npx prisma migrate dev
    npx prisma generate
    ```
4.  Inicie o servidor:
    ```bash
    node index.js
    ```
    *O servidor rodará em `http://localhost:3000`*

### **2. Configuração do Frontend**
Navegue até a pasta `frontend`:
1.  Instale as dependências do Flutter:
    ```bash
    flutter pub get
    ```
2.  Certifique-se de que o emulador ou dispositivo físico tenha acesso ao endereço do backend.
    * *Dica:* Se estiver no emulador Android, use `10.0.2.2` em vez de `localhost`.
3.  Execute o app:
    ```bash
    flutter run
    ```

---

## ✨ Funcionalidades Atuais

* **Autenticação:** Cadastro e Login com níveis de acesso (USER e ADMIN).
* **Mural de Animais:** Cadastro de pets para adoção com sistema de aprovação pelo administrador.
* **Gestão de Fornecedores:** CRUD completo para parceiros da ONG (Alimentos, Clínicas, etc.).
* **Módulo Financeiro:** Registro de doações e despesas com cálculo automático de saldo.
* **Estatísticas:** Gráficos detalhados sobre o status dos animais resgatados.
* **Candidaturas:** Sistema de envio e aprovação de pedidos de adoção.

---

## 🛡️ Notas de Segurança
* O sistema utiliza **JWT (JSON Web Tokens)** para proteger as rotas administrativas.
* Senhas são criptografadas com **Bcrypt** antes de serem salvas no banco de dados.

---

## 🤝 Contribuintes
* https://github.com/charlesalbuquerque
* https://github.com/devErickMachado

---

### Dicas para o GitHub:
1.  Crie o arquivo na raiz do projeto com o nome exato `README.md`.
2.  Ao subir, o GitHub vai renderizar esse texto bonitão com os ícones e a formatação.
3.  Não esqueça de verificar se o seu `.gitignore` está ativo para não subir a pasta `node_modules` nem o `.env`.