### Domínio: Usuário (Arkham MVP v1)

Versão: 1.0
Data: 2026-07-28
Status: **implementado** (M1)
Fontes: [PRD-Arkham-MVP-v1.md](PRD-Arkham-MVP-v1.md) FR-001/FR-002, [HLD-Arkham-MVP-v1.md](HLD-Arkham-MVP-v1.md) seções "Segurança" e "Modelo de dados"

Este documento isola tudo que diz respeito a **autenticação, cadastro e gestão de usuários** — a parte do MVP já implementada — separado do domínio de Plantão/Checklist (ver [DOMINIO-PLANTAO-v1.md](DOMINIO-PLANTAO-v1.md)), que ainda é fase futura.

---

### Entidades

**users**
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| name | string | |
| login | string | único, imutável após criação, padrão `nome.sobrenome` |
| email | string | contato/cadastro; não usado para login |
| password_digest | string | bcrypt |
| group | string | `maintainer / administrator / nursing_leaders / nursing_team / employer` |
| active | boolean | default true |
| must_change_password | boolean | força troca da senha padrão no primeiro acesso |

**refresh_tokens**
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| user_id | uuid | FK → users |
| token_digest | string | hash do token opaco, único |
| expires_at | datetime | |
| revoked_at | datetime | nullable — rotação invalida o anterior |

---

### Regras de negócio

- Login por **login** (não e-mail) + senha
- Cadastro define senha inicial = senha padrão do sistema, com troca obrigatória no primeiro acesso
- Token de acesso (JWT curto, sem revogação imediata) + refresh token (opaco, rotativo, revogável, hash no banco)
- 5 grupos hierárquicos: `maintainer, administrator, nursing_leaders, nursing_team, employer`

### Regras de propriedade de dados (M1)

| Ação | Quem pode |
| --- | --- |
| Listar usuários | somente `administrator`/`maintainer` |
| Criar usuário | somente `administrator`/`maintainer` |
| Trocar senha | o próprio usuário, ou `administrator`/`maintainer` para qualquer um |
| Trocar grupo | somente `administrator`/`maintainer` (inclusive o próprio); ninguém fora desses grupos altera nem o próprio grupo |
| Excluir usuário | somente `administrator`/`maintainer`, nunca contra a própria conta |
| Inativar usuário | mesma regra da exclusão; registro preservado, sem reativação no MVP |
| Alterar `login` | **ninguém** — imutável após criação em qualquer endpoint |

- Bloqueio central de "zerar" `administrator`/`maintainer` ativos, reaproveitado por `ChangeUserGroup`, `DestroyUser`, `InactivateUser` (`Arkham::UseCases::EnsurePrivilegedGroupRemains`)
- Para exclusão/inativação, a guarda `forbid_self_target` já torna o cenário de zerar inalcançável via API — só é alcançável via `ChangeUserGroup`, onde um privilegiado pode rebaixar a si mesmo
- Bootstrap: migração `CreateDefaultMaintainerUser` cria `maintainer` padrão (login `admin.sistema`) no primeiro deploy; roda uma única vez, sem auto-cura se removido depois; `db/seeds.rb` equivalente para `db:schema:load` + `db:seed`

---

### Convenção de erros HTTP

- Token ausente, inválido, expirado ou de usuário que não existe mais → `401` (cliente deve tentar `POST /api/auth/refresh`)
- Usuário existente porém inativo, ou violação de regra de grupo/propriedade → `403` (refresh não resolve)

---

### O que este domínio **não** cobre

A tabela completa de "o que cada grupo pode fazer" nas funcionalidades de enfermagem (execução, parametrização, financeiro, config) é RBAC por **funcionalidade**, não propriedade de dado de usuário — isso pertence ao domínio Plantão/Checklist (ver [DOMINIO-PLANTAO-v1.md](DOMINIO-PLANTAO-v1.md)). Ver também [GUIA-PERMISSOES-v1.md](GUIA-PERMISSOES-v1.md) para a explicação em linguagem não técnica dos grupos.
