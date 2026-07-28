### Guia de integração front-end: usuários, login e tokens

Versão: 1.0
Data: 2026-07-27
Referência: [PRD-Arkham-MVP-v1.md](PRD-Arkham-MVP-v1.md) (FR-001, FR-002), [ROADMAP-v1.md](ROADMAP-v1.md) (M1)

Este documento descreve os endpoints implementados no marco M1: login, refresh de token, criação de usuário, troca de senha e troca de grupo. Todos os endpoints estão sob o prefixo `/api` e trocam JSON.

**Importante:** os três endpoints de gestão de usuário (`POST /api/users`, `PUT /api/users/:id/password`, `PUT /api/users/:id/group`) já têm checagem de propriedade/grupo — ver detalhes em cada seção abaixo. O frontend deve esconder essas ações da UI conforme o grupo do usuário logado, mas isso é só uma melhoria de UX — o backend já bloqueia de verdade.

---

### Autenticação nas rotas protegidas

Rotas protegidas exigem o header:

```
Authorization: Bearer <access_token>
```

Se o token faltar, for inválido/expirado, ou o usuário não existir/estiver inativo, a resposta é `403 Forbidden`:

```json
{ "errors": "<mensagem>" }
```

---

### POST /api/auth/login

Não exige token. Autentica por `login` (não e-mail) e senha.

**Request**
```json
{
  "login": "joao.silva",
  "password": "Arkham@2026"
}
```

**Response `200 OK`**
```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "5721ca30...",
  "must_change_password": true,
  "user": {
    "id": "5b0956d5-1150-44f6-90f1-3055519e3e29",
    "name": "Joao Silva",
    "login": "joao.silva",
    "email": "joao@example.com",
    "group": "administrator",
    "active": true,
    "must_change_password": true
  }
}
```

`must_change_password: true` indica que o usuário ainda está com a senha padrão do sistema — o frontend deve redirecionar para a tela de troca de senha antes de liberar o restante do app.

**Erros**
| Status | Situação |
| --- | --- |
| `401 Unauthorized` | login ou senha incorretos |
| `403 Forbidden` | usuário existe mas está inativo |
| `422 Unprocessable Entity` | `login` ou `password` ausentes no payload |

---

### POST /api/auth/refresh

Não exige o header `Authorization`. Troca um refresh token válido por um novo par de tokens (token de acesso + refresh token). **O refresh token usado é invalidado nessa troca** (rotação) — guarde sempre o novo `refresh_token` retornado, o anterior não pode ser reutilizado.

**Request**
```json
{
  "refresh_token": "5721ca30..."
}
```

**Response `200 OK`**

Mesmo formato do login (novo `access_token`, novo `refresh_token`, `must_change_password`, `user`).

**Erros**
| Status | Situação |
| --- | --- |
| `401 Unauthorized` | refresh token inválido, expirado, já utilizado, ou usuário associado não existe mais |
| `403 Forbidden` | usuário associado ao token está inativo |
| `422 Unprocessable Entity` | `refresh_token` ausente no payload |

**Recomendação de uso:** ao receber `401` de qualquer chamada autenticada, tente uma vez `POST /api/auth/refresh`; se também falhar, redirecione para o login.

---

### POST /api/users — criar usuário

Requer `Authorization: Bearer <access_token>` de um usuário `administrator`/`maintainer` — qualquer outro grupo recebe `403`. A senha inicial é sempre a senha padrão do sistema — não é enviada no payload nem escolhida pelo frontend.

**Bootstrap:** o sistema garante, via migração, que sempre existe pelo menos um usuário `maintainer` (login `admin.sistema`) desde o primeiro deploy, para que sempre haja alguém apto a chamar este endpoint.

**Request**
```json
{
  "user": {
    "name": "Maria Souza",
    "login": "maria.souza",
    "email": "maria@example.com",
    "group": "nursing_team"
  }
}
```

Campos:
| Campo | Regra |
| --- | --- |
| `name` | obrigatório |
| `login` | obrigatório, único, padrão `nome.sobrenome` (letras minúsculas/números separados por ponto) |
| `email` | obrigatório, formato de e-mail válido |
| `group` | obrigatório, um de: `maintainer`, `administrator`, `nursing_leaders`, `nursing_team`, `employer` |

**Response `200 OK`**
```json
{ "id": "f8886c60-4415-4740-84b6-14a9344aa57c" }
```

**Erros**
| Status | Situação |
| --- | --- |
| `403 Forbidden` | token ausente/inválido, usuário do token inativo, **ou** quem chama não é `administrator`/`maintainer` |
| `422 Unprocessable Entity` | `login` já existe, campo obrigatório ausente, `login` fora do padrão, ou `group` inválido |

Mensagem de erro do caso de propriedade:
```json
{ "error": "Only administrator or maintainer can perform this action" }
```

---

### PUT /api/users/:id/password — trocar senha

Requer `Authorization`. Usado tanto para a troca obrigatória da senha padrão quanto para troca de senha espontânea.

**Quem pode chamar para qual `:id`:** o próprio usuário (`:id` igual ao usuário do token), ou qualquer usuário `administrator`/`maintainer` alterando a senha de terceiros. Qualquer outro caso retorna `403`. **O campo `login` não pode ser alterado por este endpoint** (nem por nenhum outro) — se enviado no payload, é ignorado.

**Request**
```json
{
  "current_password": "Arkham@2026",
  "new_password": "NovaSenha123"
}
```

**Response `200 OK`**
```json
{ "id": "5b0956d5-1150-44f6-90f1-3055519e3e29" }
```

**Erros**
| Status | Situação |
| --- | --- |
| `401 Unauthorized` | `current_password` não confere com a senha atual do usuário `:id` |
| `403 Forbidden` | token ausente/inválido, **ou** quem chama não é o próprio `:id` nem `administrator`/`maintainer` |
| `404 Not Found` | usuário `:id` não existe |
| `422 Unprocessable Entity` | `new_password` ausente ou com menos de 6 caracteres |

Mensagem de erro do caso de propriedade:
```json
{ "error": "You can only modify your own data" }
```

---

### PUT /api/users/:id/group — alterar grupo de um usuário

Requer `Authorization`. **Somente `administrator`/`maintainer` pode chamar este endpoint** — inclusive para alterar o próprio grupo. Um usuário fora desses grupos recebe `403` mesmo tentando alterar o próprio grupo (evita que um usuário se autopromova). Também bloqueia a alteração se ela deixar o sistema **sem nenhum** usuário ativo `administrator` ou `maintainer`.

**Request**
```json
{ "group": "nursing_leaders" }
```

**Response `200 OK`**
```json
{ "id": "5b0956d5-1150-44f6-90f1-3055519e3e29" }
```

**Erros**
| Status | Situação |
| --- | --- |
| `403 Forbidden` | token ausente/inválido, **ou** quem chama não é `administrator`/`maintainer` |
| `404 Not Found` | usuário `:id` não existe |
| `422 Unprocessable Entity` | `group` inválido, ou a alteração deixaria o sistema sem nenhum `administrator`/`maintainer` ativo |

Mensagem de erro do caso de propriedade:
```json
{ "error": "Only administrator or maintainer can perform this action" }
```

Mensagem de erro nesse último caso:
```json
{ "error": "At least one active administrator or maintainer must remain" }
```
O frontend deve tratar esse caso com uma mensagem amigável (ex.: "Não é possível remover o último administrador do sistema").

---

### Resumo de status HTTP usados

| Status | Significado neste módulo |
| --- | --- |
| 200 | sucesso |
| 401 | credenciais/senha/token de refresh incorretos ou expirados |
| 403 | token de acesso ausente/inválido, usuário inativo, ou violação de regra de propriedade/grupo (ex.: tentar editar dados de outro usuário sem ser administrator/maintainer) |
| 404 | usuário referenciado não encontrado |
| 422 | payload inválido ou regra de negócio violada (login duplicado, último admin) |
