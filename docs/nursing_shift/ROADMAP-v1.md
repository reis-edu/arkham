### Roadmap de entrega: Arkham MVP v1 (passagem de plantão)

Versão: 1.0
Data: 2026-07-27
Referência: [PRD-Arkham-MVP-v1.md](PRD-Arkham-MVP-v1.md), [HLD-Arkham-MVP-v1.md](HLD-Arkham-MVP-v1.md)

---

Este roadmap sequencia a entrega do MVP em marcos incrementais e testáveis. A ordem segue dependência técnica (autenticação e cadastros antes de checklist, checklist antes de relatório), não apenas a prioridade declarada no PRD.

---

### M1 — Grupos de usuário e login JWT
**Status:** ✅ done (2026-07-27)
**FRs:** FR-001, FR-002

Escopo confirmado com o time (2026-07-27):
- [x] Cadastro de usuário com nome, login (`nome.sobrenome`), senha, e-mail e grupo de acesso
- [x] Criação de usuário com senha padrão do sistema, a ser trocada pelo próprio usuário depois
- [x] Endpoint de troca de senha
- [x] Endpoint de alteração de grupo de um usuário
- [x] Login por **login** (não e-mail) + senha, emitindo token de acesso (JWT) e refresh token
- [x] Mecanismo de refresh token seguindo padrão de mercado (rotativo, opaco, revogável, armazenado com hash)
- [x] Regra de segurança: bloquear alteração de grupo que deixe o sistema sem nenhum usuário `administrator`/`maintainer` ativo
- [x] Testes unitários cobrindo todos os cenários acima (casos de sucesso e erro) — 64 exemplos, spec/use_cases, spec/repository e spec/controllers

**Fora do escopo deste marco (adiado para fase futura):**
- Bloqueio de rota por grupo/permissão — nas rotas implementadas aqui, a validação é apenas: usuário existe, está ativo e o token de acesso é válido
- Qualquer autorização por grupo (ex.: "só administrator pode criar usuário") fica documentada como regra de negócio, mas **não é aplicada** como guarda de rota nesta fase

**Entregável testável:** usuário é criado com senha padrão, faz login, troca a própria senha, renova o token via refresh token, e uma tentativa de deixar o sistema sem `administrator`/`maintainer` é bloqueada. Validado manualmente via HTTP (curl) e via suíte automatizada.

**Doc complementar criada:** [GUIA-FRONTEND-AUTENTICACAO-v1.md](GUIA-FRONTEND-AUTENTICACAO-v1.md) — endpoints e payloads para login, troca de senha, alteração de grupo e criação de usuário.

**Notas de implementação (para quem retomar este marco):**
- Corrigido um bug de segurança pré-existente: `JsonWebToken::SECRET_KEY` estava fixado como string vazia (`""`), permitindo qualquer JWT ser forjado. Agora usa `Rails.application.secret_key_base`. Isso afeta também o login de `Visitor`, que reaproveita a mesma classe.
- Corrigida a causa raiz das 20 falhas de `CpfUtils` nos specs de Patient: o `docker-compose.yml` fixa `RAILS_ENV: development` no container, e `spec/rails_helper.rb` usava `ENV['RAILS_ENV'] ||= 'test'` — como a env var do container já vinha preenchida, o `||=` nunca forçava o ambiente de teste, então `Bundler.require` nunca carregava o grupo `:test` do Gemfile (onde vive `cpf_utils`). Trocado para `ENV['RAILS_ENV'] = 'test'` (atribuição incondicional); `bundle exec rspec` agora sempre roda em `test` independentemente do env do container. Suíte completa: 141 exemplos, 0 falhas.
- Senha padrão e TTLs de token ficam em `config/arkham.yml` (`users.default_password`, `users.access_token_expiration`, `users.refresh_token_expiration`).
- Especificações de controller neste projeto **não conseguem** mockar `Arkham::Dependencies` a partir do `before`/`it` do exemplo — o `rspec-rails` instancia `@controller` (e portanto chama `initialize`) antes desses hooks rodarem. Os specs de `patients_controller` já seguiam esse padrão (rodam contra a implementação real); os novos specs de `users_controller`/`authentication_controller` fazem o mesmo — banco real via FactoryBot, sem mocks de Dependencies.

**Refinamento pós-fechamento do marco (2026-07-27):** as regras de propriedade de dados foram estendidas a `POST /api/users` — agora exige `administrator`/`maintainer`, igual a `PUT /api/users/:id/group`. Isso fechou a última rota de gestão de usuário sem checagem de grupo. Para viabilizar isso sem deixar o sistema sem ninguém apto a criar usuários, foi adicionada a migração `db/migrate/20260727130000_create_default_maintainer_user.rb`, que cria um `maintainer` padrão (login `admin.sistema`) no primeiro deploy — roda uma única vez (semântica padrão de migração), não recria o usuário se ele for removido depois. Existe também `db/seeds.rb` equivalente para o caminho `db:setup`/`db:schema:load` + `db:seed`, que não reexecuta migrações antigas.

**Tarefas futuras identificadas (não fazem parte deste marco):**
- [ ] Aplicar o bloqueio de rota por grupo nas futuras rotas de plantão/checklist (fora do escopo de usuários/M1), consumindo a matriz de permissões já documentada no PRD
- [ ] Decidir se/como será feito rate limiting e alertas sobre tentativas de login inválidas repetidas (força bruta) — fora do escopo original deste marco

---

### M2 — Cadastros do ADM
**FRs:** parte de FR-003 (pré-requisito)

- CRUD de usuários pelo ADM (com senha inicial)
- Cadastro de itens de checklist
- Cadastro de atividades com periodicidade (diária, semanal, quinzenal, mensal, múltiplas vezes ao dia, horário fixo, dia fixo da semana)
- Atribuição de atividade a plantão ou a usuário

**Entregável testável:** ADM cadastra usuário, item e atividade; regra de periodicidade é persistida corretamente.

---

### M3 — Execução do plantão (checklist)
**FRs:** FR-003 (núcleo)

- Materialização das atividades aplicáveis a cada plantão conforme periodicidade
- Marcar/desmarcar item com salvamento contínuo
- Finalização do plantão (execução)
- Item "impossível de cumprir": motivo obrigatório + notificação síncrona (WhatsApp)
- Auditoria (quem, quando, o quê) nas mutações

**Entregável testável:** plantão exibe os itens corretos do dia; enfermagem finaliza execução; auditoria registra o evento.

---

### M4 — Revisão e divergência
**FRs:** FR-003 (continuação)

- Revisão do plantão seguinte com salvamento contínuo
- Finalização da revisão: correto ou com divergência registrada (auditável)
- Notificação síncrona (WhatsApp) em caso de divergência
- Restrição de edição pós-finalização (só ADM)
- Visibilidade diferenciada: Enfermagem vê nível combinado; ADM vê divergências e status agregado

**Entregável testável:** ciclo completo execução → revisão → finalização com/sem divergência, visível conforme perfil.

---

### M5 — Listagem e relatório de plantões
**FRs:** FR-004

- Listagem de plantões por período
- Detalhe ao abrir (o que foi checado/revisado), respeitando visibilidade por perfil

**Entregável testável:** ADM e Enfermagem consultam listagem e detalhe, cada um vendo o que é permitido ao seu perfil.

---

### M6 — Operações do perfil Desenvolvedor
**FRs:** FR-005

- Parâmetros de sistema
- Exportação de auditoria
- Impersonação (com trilha de auditoria própria)

**Entregável testável:** Desenvolvedor acessa as três funções; demais perfis recebem 403.

---

### M7 — Observabilidade e contingência
**NFRs do PRD**

- Logs estruturados + tracing distribuído; stack trace e input mascarado em erro
- Alertas de indisponibilidade; rastreio de rotas mais lentas
- Rate limit global (100 req/min)
- Fluxo de contingência sem internet: ADM encerra plantão com pendência "Sistema indisponível"
- Política de retenção/arquivamento (5 anos)

**Entregável testável:** dashboards no Grafana Cloud mostrando latência/erro por rota; alerta dispara em indisponibilidade simulada.

---

### Fora deste roadmap (fora de escopo do MVP)
Conforme PRD: área do cliente/familiares, cadastro de pacientes vinculado a atividades, medicação, anotações clínicas, prontuário, LGPD formal, MFA, offline/filas assíncronas.

---

### Notas de sequenciamento
- Testes (unitários, integração API+banco, contrato) acompanham cada marco — não é uma fase separada ao final, conforme estratégia de TDD do PRD.
- M1 e M2 são bloqueantes para todo o resto; M3/M4 formam o núcleo de valor do produto; M5 e M6 podem ser paralelizados entre si após M4; M7 é transversal e pode começar já em M1 (logs/tracing básicos) e se aprofundar ao longo dos marcos.
