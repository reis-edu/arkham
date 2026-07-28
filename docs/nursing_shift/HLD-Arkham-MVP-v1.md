### HLD: Arkham Backend (MVP v1)

Versão: 1.0 (HLD)  
Data: 2026-04-05  
Responsável: a definir

---

### Objetivo técnico

Entregar o **backend** do Arkham MVP v1 como **serviço único em Ruby on Rails**, implantado na **Koyeb**, expondo **API REST** sob o prefixo **`/api`**, com **PostgreSQL gerenciado** na mesma plataforma, **JWT** e **autorização por perfil**, fluxos de **plantão e checklist** com **auditoria transacional**, **notificação síncrona** para **WhatsApp** (provedor a definir) e **observabilidade** com **OpenTelemetry** para **Grafana Cloud**. O desenho prioriza **simplicidade operacional** (uma réplica, sem cache, sem fila, sem API Gateway e sem load balancer gerenciado pelo time), compatível com **baixo volume** de usuários e com o **frontend** mantido em **outro repositório e outro time**.

Dependências com outros sistemas
- **Frontend web** (consumidor principal da API, contrato via **OpenAPI**)
- **Koyeb** (runtime da API e **Postgres** gerenciado)
- **Grafana Cloud** (logs, métricas e traces)
- **Provedor WhatsApp** (integração **a definir**, chamada **HTTPS** síncrona)
- **Ferramentas de teste** (Postman e similares) sobre **HTTPS**

---

### Arquitetura geral

**Topologia lógica:** um **processo Rails** (Puma) atende **HTTP** na borda da **Koyeb**; o mesmo processo orquestra **autenticação**, **regras de negócio**, **acesso ao Postgres** e **cliente de notificação**; **telemetria** exporta via **OTLP** para o **Grafana Cloud**. **Não há** fila, **cache** nem **segundo serviço** de aplicação na v1.

Ambiente de implantação
- **Nuvem** (Koyeb)
- **API:** um **deploy** com **uma réplica**; **Postgres** gerenciado na Koyeb; **TLS** conforme a plataforma

Tecnologias principais
- **Ruby on Rails** (serviço de API, detalhes de gems no FDD)
- **PostgreSQL** (Koyeb)
- **OpenTelemetry** e **Grafana Cloud**
- **REST** e **JSON** sobre **HTTPS**

Padrões adotados
- **API REST** com contrato **OpenAPI**
- **Autenticação stateless** com **JWT** (sem revogação imediata no servidor na v1)
- **Autorização por perfil** (RBAC) por rota ou guarda central equivalente
- **Transações** no **Postgres** para operações críticas, com **auditoria na mesma transação** que altera o checklist quando aplicável
- **Processamento síncrono** na v1 (incluindo tentativa de **WhatsApp** no fluxo da requisição)

---

### Componentes e responsabilidades

| Componente | Responsabilidades | Dependências |
| ----------- | ----------------- | ------------ |
| **Camada HTTP (`/api`)** | Roteamento, **CORS**, limite **global** de taxa (**100 req/min**), serialização **JSON**, mapeamento de erros HTTP | Middleware de auth, casos de uso |
| **Autenticação, JWT e refresh token** | Cadastro de usuário (nome, login, senha, e-mail, grupo) por **administrator/maintainer** com senha padrão; login por **login** (não e-mail); emissão de **token de acesso** (JWT curto) e **refresh token** (opaco, rotativo, armazenado com hash); troca de senha; usuário desativado bloqueado | Postgres (usuários, refresh tokens), segredo de assinatura na Koyeb |
| **Grupos de permissão** | Manter os 5 grupos (**maintainer, administrator, nursing_leaders, nursing_team, employer**), matriz de permissão testável no código; impedir alteração de grupo que zere **administrator/maintainer** ativos; **v1/M1 sem bloqueio de rota por grupo** (ver PRD FR-002) | Claims do JWT, regras por rota (fase futura) |
| **Domínio plantão e checklist** | Materializar o que se aplica ao plantão, **salvamento contínuo**, finalização de execução e revisão, divergência e impossível cumprir conforme PRD | Postgres, auditoria, opcionalmente cliente WhatsApp |
| **Cadastros ADM** | Usuários, itens, atividades com **periodicidade** e atribuições | Postgres, auditoria |
| **Listagem e consulta de plantões** | Relatórios e detalhes com **visibilidade por perfil** | Postgres |
| **Auditoria** | Registrar eventos **quem, quando, o quê** em linha com o PRD | Postgres (mesma transação que mutações críticas quando definido) |
| **Cliente de notificação (WhatsApp)** | Chamada **síncrona** **HTTPS** nos gatilhos do PRD | Provedor externo **a definir**, política de timeout e falha no FDD |
| **Observabilidade** | **Logs** estruturados, **métricas** e **traces** via **OTel** para **Grafana Cloud**; correlação request e trace | Grafana Cloud, runtime Koyeb |
| **Operações perfil Desenvolvedor** | Parâmetros de sistema, exportação de auditoria, **impersonação** conforme PRD e FDD | Postgres, trilhas de auditoria |

---

### Fluxo de requisições e de dados

**Fluxo de requisição** (exemplo: **salvar checagem** no plantão em andamento)
- Cliente (**frontend** ou ferramenta) chama **`HTTPS`** o endpoint em **`/api/...`** na Koyeb
- A plataforma termina **TLS** e encaminha ao processo **Rails**
- **Middleware** aplica **limite global** (**100 req/min**), depois valida **JWT** e **perfil**
- **Handler** chama o **caso de uso**, que valida **estado do plantão** e **permissões**
- Abre **transação** no **Postgres**: persiste a **checagem** e o **evento de auditoria** no **mesmo commit**
- Responde **JSON**; em paralelo, **OTel** envia **spans** e telemetria ao **Grafana Cloud**

**Fluxo de dados**
- **Entrada:** payload JSON da API, identidade do **JWT**
- **Transformação:** regras de domínio e validações; gravação **relacional** com **integridade transacional**
- **Destino durável:** **Postgres** (estado de plantão, checagens, revisões, cadastros, auditoria)
- **Variante (impossível cumprir / divergência):** após **persistir** o necessário na mesma requisição, o serviço chama o **provedor WhatsApp** de forma **síncrona**; falha externa impacta **latência** ou **resposta** conforme política no **FDD**
- **Telemetria:** métricas, traces e logs para **Grafana Cloud**; **alertas** também consideram sinais da **Koyeb**

---

### Modelo de dados (alto nível)

Entidades principais
- **Usuário** (nome, login, senha, e-mail, grupo, ativo) e vínculo com **grupo de permissão**
- **Refresh token** (usuário, hash do token, expiração, revogado em)
- **Item** de checklist (catálogo)
- **Atividade** com **periodicidade** e **atribuição** (plantão ou usuário)
- **Plantão**
- **Ocorrências materializadas** para execução e revisão no plantão
- **Estado de execução e revisão** (incluindo **divergência** quando houver)
- **Evento de auditoria**
- **Parâmetros de sistema** (operações do perfil **Desenvolvedor**)

Relações
- **Atividades** e regras de **periodicidade** determinam o que **aparece** em cada **plantão**
- **Checagens** e **revisões** referenciam **plantão**, **usuário** e itens aplicáveis
- **Eventos de auditoria** referenciam **entidades** e **ações** relevantes

Fonte de verdade
- **PostgreSQL** gerenciado pela **Koyeb** (instância única na v1, **sem réplica de leitura**)
- **Política de retenção:** **arquivar após 5 anos** dados de **auditoria** e **histórico operacional** de plantões (mecanismo de arquivamento no **FDD**)

---

### Interfaces públicas

| Nome | Tipo | Protocolo | Exposição | SLAs/Limites |
| ---- | ---- | ---------- | --------- | ------------- |
| **Arkham API** | API | **REST**, **JSON**, **HTTPS**; prefixo **`/api`**; **sem** segmento de versão no path; contrato **OpenAPI** | **Externa** para frontend e ferramentas; **CORS** para origens do frontend | Meta PRD: operações típicas de checklist **até ~1 s** na rede da instituição na maior parte dos casos; **99,5%** uptime mensal em produção; **100 req/min** **globais** (não por IP nem por usuário) |
| **WhatsApp (provedor)** | Integração saída | **HTTPS** (detalhe no FDD) | **Interna** (serviço chaveia para fora) | **Síncrono** no request path; **timeouts** e degradação no **FDD** |
| **OTLP (Grafana Cloud)** | Telemetria | **OTLP** (HTTP ou gRPC conforme FDD) | **Interna** | Limites conforme plano **Grafana**; amostragem de traces no **FDD** |

---

### Considerações de escalabilidade e disponibilidade

Abordagem geral
- **Uma réplica** da API na v1; **sem** escalonamento horizontal da aplicação; crescimento por **capacidade vertical** ou ajuste de plano na **Koyeb** se necessário
- **Postgres** único; **sem sharding** e **sem cache** na v1

Técnicas aplicadas
- **Rate limiting global** (**100 req/min**) como proteção simples
- **Transações** para consistência; **auditoria** alinhada às mutações críticas
- **Backpressure** implícito pelo **rate limit**; integração **síncrona** com WhatsApp pode **aumentar** latência ou gerar erro conforme política

Meta de disponibilidade
- **99,5%** uptime mensal em produção (**PRD**), dependente de **Koyeb**, **Postgres** e conectividade

---

### Segurança

Autenticação
- **Login** (padrão `nome.sobrenome`, não e-mail) e **senha**; cadastro com **senha padrão** trocada posteriormente pelo usuário; **token de acesso** (JWT curto) e **refresh token** (opaco, rotativo, revogável) nas rotas protegidas; **sem MFA** na v1 (**PRD**)
- **Convenção de status HTTP:** token ausente, inválido, expirado ou de usuário que não existe mais → **`401 Unauthorized`** (sinal para o cliente tentar `POST /api/auth/refresh`); usuário existente porém **inativo**, ou violação de regra de grupo/propriedade → **`403 Forbidden`** (refresh não resolve, é preciso reativação ou permissão diferente)

Autorização
- Modelo de **5 grupos** (**maintainer, administrator, nursing_leaders, nursing_team, employer**) com matriz de permissão versionada no código
- **M1 (implementado) — regras de propriedade de dados nos endpoints de usuário:**
  - Listagem de usuários: **apenas administrator/maintainer**; qualquer outro ator recebe `403`
  - Criação de usuário: **apenas administrator/maintainer**; qualquer outro ator recebe `403`
  - Troca de senha: **próprio usuário** ou **administrator/maintainer** podem trocar a senha de um usuário; qualquer outro ator recebe `403`
  - Troca de grupo: **apenas administrator/maintainer** (nunca "self" se não privilegiado, para impedir auto-escalonamento de privilégio); qualquer outro ator recebe `403`
  - Exclusão e inativação de usuário: **apenas administrator/maintainer**, e **nunca contra a própria conta** (guarda `forbid_self_target`, distinta da checagem de grupo); qualquer violação recebe `403`
  - **Login é imutável** em qualquer endpoint pós-criação (nenhum contract de update aceita o campo `login`)
- **Bootstrap:** uma migração de banco (`CreateDefaultMaintainerUser`) cria um usuário `maintainer` padrão (login `admin.sistema`) no primeiro deploy, garantindo que sempre exista alguém apto a criar os demais usuários; roda uma única vez (semântica padrão de migração Rails) — se o usuário for removido depois, não é recriado automaticamente. Há também um `db/seeds.rb` equivalente para o caminho `db:schema:load` + `db:seed`, que não reexecuta migrações antigas
- Alteração, exclusão ou inativação de usuário é bloqueada se resultar em **zero** usuários **administrator/maintainer** ativos — regra centralizada em `Arkham::UseCases::EnsurePrivilegedGroupRemains`, reaproveitada pelos três use cases (`ChangeUserGroup`, `DestroyUser`, `InactivateUser`). Para exclusão/inativação essa checagem é defesa em profundidade: como quem executa a ação já precisa ser `administrator`/`maintainer` diferente do alvo (guarda `forbid_self_target`), o cenário de "zerar" não é alcançável via API hoje — só via `ChangeUserGroup`, onde um privilegiado pode rebaixar a si mesmo
- **M1 (fase futura):** as rotas de plantão/checklist (fora do escopo de M1) ainda não existem; quando existirem, aplicarão a matriz de permissão completa por grupo (ver PRD FR-002)

Proteção de dados
- **HTTPS** obrigatório em produção (**PRD**)
- **Repouso:** criptografia **gerenciada** pelo **Postgres** da Koyeb
- **Logs:** mascarar **senha** e **tokens** (**PRD**); **PII** adicional em logs e traces **a definir** no **FDD** com **política mínima**; **LGPD** formal fora do escopo v1 (**PRD**), com risco residual reconhecido

Gestão de segredos
- **Secrets** e variáveis protegidas na **Koyeb** (JWT, Postgres, **OTLP/Grafana**, credenciais **WhatsApp**)
- **Token de acesso (JWT)** de curta duração, **sem** revogação imediata no servidor dentro do seu próprio TTL
- **Refresh token** é **revogável**: armazenado com hash no Postgres, **rotativo** (cada uso emite um novo par e invalida o anterior), com expiração própria (mais longa que o token de acesso)

---

### Observabilidade

Logs
- **Estruturados**, enviados ao **Grafana Cloud** (pipeline exato, por exemplo **Loki** ou logs via **OTel**, no **FDD**)
- Em **erro**, **stack trace** e dados de entrada com **mascaramento** de segredos (**PRD**)

Métricas
- **Latência**, **taxa de erro** e **volume** por rota ou serviço; apoio ao requisito de identificar **rotas mais lentas** (**PRD**)

Tracing
- **OpenTelemetry** com exportação ao **Grafana Cloud**; **correlação** entre trace e logs quando aplicável

Dashboards e alertas
- **Dashboards** no **Grafana Cloud**
- **Alertas** configurados **na Koyeb** e **no Grafana Cloud** para **indisponibilidade** e **degradação**

---

### Riscos arquiteturais e mitigação

#### Queda de internet impede uso digital no horário
- **Probabilidade:** baixa
- **Impacto:** impossibilidade de concluir passagem digital até restabelecer conectividade; risco operacional no período
- **Mitigação:**
  - Fluxo operacional de **acordo verbal** enquanto indisponível (**PRD**)
  - Após retorno, **ADM** encerra plantão com pendência **Sistema indisponível** (**PRD**)
- **Plano de contingência:** continuidade operacional fora do sistema até voltar a rede; reconciliação no sistema depois

#### Vazamento de informações por logs ou acesso indevido a logs
- **Probabilidade:** baixa
- **Impacto:** exposição de dados de colaboradores e dano reputacional
- **Mitigação:**
  - Mascarar **senha** e **tokens** em logs (**PRD**)
  - Restringir acesso operacional a logs ao perfil **Desenvolvedor** (**PRD**)
  - Definir **política mínima** de **PII** em logs e traces no **FDD**
- **Plano de contingência:** acionar **resposta a incidente** institucional

#### Falha ou lentidão do WhatsApp no caminho síncrono
- **Probabilidade:** média
- **Impacto:** aumento de **latência**, **timeout** ou **erro** na API nos gatilhos que chamam o provedor
- **Mitigação:**
  - **Timeouts** e política clara de **sucesso parcial** (negócio persistido, notificação falhou) ou **erro**, conforme **FDD**
  - Considerar **circuit breaker** ou limites de tempo como **hipótese** no **FDD**
- **Plano de contingência:** retry manual ou canal alternativo definido pela operação; evolução futura para **fila** se sair do escopo v1

#### Disponibilidade limitada por SPOF da API e do Postgres (uma réplica, banco sem réplica de leitura)
- **Probabilidade:** depende do provedor; tratar como risco **operacional contínuo**
- **Impacto:** indisponibilidade **total** do backend durante incidente na **Koyeb** ou no **Postgres**
- **Mitigação:**
  - Confiar em **SLA** e **suporte** Koyeb; **backups** do Postgres gerenciado
  - Runbook de **redeploy** e comunicação com o time do **frontend**
- **Plano de contingência:** aceitar janela no **MVP** ou planejar **réplicas** e **read replica** em fase posterior

#### JWT sem revogação imediata até expirar
- **Probabilidade:** baixa de incidente; impacto **médio** se token for comprometido
- **Mitigação:**
  - **TTL** adequado e boas práticas de armazenamento no cliente (orientação ao time do **frontend**)
  - Em incidente, **rotação de chave** de assinatura e invalidação prática via **redeploy** ou mudança de segredo, detalhada no **FDD**
- **Plano de contingência:** forçar **troca de senha** e **expiração natural** dos tokens emitidos com chave antiga após rotação

---

### ADRs e próximos passos

ADRs associados
- **Não há ADRs** escritos; **sugestão de ADRs a criar:** token de acesso (JWT) sem revogação + refresh token opaco rotativo revogável; login por **login** (`nome.sobrenome`) em vez de e-mail; modelo de **5 grupos** com matriz de permissão em código (sem tabela de configuração); M1 sem bloqueio de rota por grupo; Postgres único na Koyeb; processamento síncrono sem fila; backend em **Ruby on Rails**; deploy na **Koyeb**; observabilidade **OTel + Grafana Cloud**; prefixo **`/api`** sem versão no path; **rate limit global**; **auditoria na mesma transação**; retenção **5 anos** com arquivamento

Decisões pendentes
- Ajustes finos de **camada de dados** (Active Record) e organização de gems em **Ruby on Rails** (**FDD**)
- **Provedor e API** de **WhatsApp**; política de **timeout** e **erro**
- Pipeline exato de **logs** para **Grafana Cloud** (**Loki** versus **OTel logs**, etc.)
- **Política mínima** de **PII** em logs e traces
- **TTL** do **JWT** e detalhes de **claims**
- Comportamento exato quando **WhatsApp** falha após persistência do negócio

Próximos passos
- Publicar **OpenAPI** e alinhar com o time do **frontend**
- Definir **migrações** e modelo físico no **FDD** (a partir do modelo lógico deste HLD)
- Implementar **testes** unitários, **integração API e banco** e **contrato** no pipeline (**PRD**)
- Redigir **ADRs** para decisões acima
- Detalhar **SLOs** e painéis no **Grafana** e revisar **alertas** duplicados (**Koyeb** e **Grafana**) para evitar ruído
