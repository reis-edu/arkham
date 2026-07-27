### PRD: Arkham MVP v1 (aplicação)

Versão: 1.0  
Data: 2026-04-05  
Responsável: a definir

---

### Resumo

O Arkham é uma aplicação nova, ainda sem produção, para apoiar fluxos centrais de uma casa de repouso. A primeira versão foca em passagem de plantão com checklist auditável (execução e revisão), autenticação e autorização por perfis, cadastro e distribuição de atividades com periodicidade variada, e uma listagem de plantões para consulta. Objetivo de negócio: reduzir falhas na passagem, padronizar registro, agilizar apuração e preparar transparência futura com familiares (fora do MVP). O backend expõe API REST com JWT; o frontend consome essa API. Hospedagem em nuvem de mercado, banco PostgreSQL.

---

### Contexto e problema

Público-alvo
- Administração (ADM)
- Enfermagem
- Desenvolvedor (perfil técnico para operações críticas)

Cenários de uso chave
- Plantão vigente executa checklist com salvamento contínuo e finaliza o plantão
- Plantão seguinte revisa itens com salvamento contínuo e finaliza a revisão (correto ou com divergência registrada)
- ADM cadastra usuários, define senha inicial, cadastra itens e atividades, atribui a plantão ou a usuário, acompanha status e divergências, encerra pendências operacionais quando o sistema ficou indisponível
- Desenvolvedor acessa parâmetros de sistema, exportação de auditoria, impersonação e logs conforme política de acesso

Onde essa feature será implantada
- Sistema novo em nuvem de mercado, composto por backend REST (JWT e checagem de perfil por endpoint) e frontend separado, com PostgreSQL como banco relacional. Processamento síncrono na v1, sem filas. Integração de WhatsApp para notificações: gatilho definido no produto, meio técnico a definir.

Problemas priorizados
- Passagens de plantão com lacunas e impossibilidade de atribuir responsabilidade ao plantão correto (prioridade alta)
- Ausência de controle confiável; planilha gerou resistência, alterações posteriores e perda de conformidade e confiabilidade (prioridade alta)

---

### Objetivos e métricas

| Objetivo                                                               | Métrica                                                         | Meta                      |
| ---------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------- |
| Maior transparência e controle na passagem de plantão                  | Percentual de passagens com checklist completo e assinado ou confirmado de forma auditável | 75% das trocas de plantão em 3 a 6 meses |
| Maior adesão ao checklist                                              | Percentual de itens obrigatórios preenchidos por passagem       | 80% em 3 a 6 meses      |
| Menos tempo gasto com apuração                                         | Minutos médios para fechar uma apuração                         | Cair de 6 h para 10 min em média em 3 a 6 meses |

---

### Escopo

Incluso
- Passagem de plantão em duas etapas: Execução (plantão vigente) e Revisão (plantão seguinte), com salvamento contínuo antes da finalização
- Cadastro de atividades pelo ADM com periodicidade (diária, semanal, quinzenal, mensal, múltiplas vezes no dia, horário fixo, dia fixo da semana), atribuição por plantão ou por usuário
- Impossível cumprir item: motivo obrigatório em texto; tentativa síncrona de notificar coordenação via WhatsApp (canal a definir tecnicamente)
- Divergência na revisão: permitir concluir com divergência registrada de forma auditável; tentativa síncrona de notificar via WhatsApp (canal a definir)
- Auditoria de alterações no fluxo (quem, quando, o que)
- Visibilidade: enfermagem vê o que foi checado e revisado no nível combinado; ADM vê também anotações de divergência e status agregado (OK ou com divergência), para mediar atritos
- Listagem de plantões (tipo relatório do dia) com detalhe ao abrir (prioridade baixa)
- Login com e-mail e senha criados pelo ADM e troca de senha pelo usuário; JWT e autorização por perfil
- Perfis: Desenvolvedor, ADM, Enfermagem, com permissões descritas neste PRD
- Observabilidade: logs estruturados com tracing, erro com stack trace e dados de entrada (com mascaramento de segredos), alerta de indisponibilidade, rastreamento de lentidão e rotas mais lentas
- Contingência operacional sem internet: acordo verbal; após retorno, ADM encerra plantão com pendência "Sistema indisponível"

Fora de escopo
- Área do cliente (familiares)
- Cadastro de pacientes e vínculo paciente x atividade no MVP
- Administração de medicamentos
- Anotações de enfermagem e anotações médicas
- Fichas de anamnese
- Fluxo de internação
- Requisitos formais de LGPD na versão 1
- MFA
- Resiliência offline e filas assíncronas na v1
- Definição técnica fechada do provedor de WhatsApp

---

### Requisitos funcionais

#### FR-001 Autenticação (login) e JWT
Permitir acesso ao sistema com e-mail e senha definidos pelo ADM, com troca de senha pelo usuário, emitindo JWT para consumo da API.

**Fluxo principal**
- ADM cria usuário com e-mail e senha inicial
- Usuário autentica na API e recebe JWT com claims necessárias ao controle de acesso
- Usuário altera senha quando aplicável ao fluxo de primeiro acesso

**Fluxos alternativos e exceções**
- Usuário desativado não autentica

**Erros previstos**
- Credenciais inválidas
- Usuário desativado

**Prioridade:** alta

---

#### FR-002 Perfis, permissões e autorização por endpoint
Garantir que cada ação na API só ocorra se o JWT representar um perfil autorizado, com regras distintas para Desenvolvedor, ADM e Enfermagem.

**Fluxo principal**
- Cada requisição autenticada carrega JWT
- O backend valida autenticidade e autorização conforme perfil e rota
- Operações sensíveis do Desenvolvedor ficam restritas a esse perfil

**Fluxos alternativos e exceções**
- Tentativa de acesso sem permissão retorna erro de autorização

**Erros previstos**
- Usuário sem permissão para a rota ou ação

**Prioridade:** média

---

#### FR-003 Passagem de plantão com checklist (execução, revisão, cadastro e auditoria)
Permitir o ciclo completo de plantão com itens gerados conforme periodicidade e atribuições, execução com salvamento contínuo, revisão com salvamento contínuo, finalizações auditáveis, tratamento de impossibilidade e divergência, e visibilidade diferenciada para ADM.

**Fluxo principal**
- ADM cadastra itens e atividades com regras de periodicidade e atribuição por plantão ou por usuário
- O sistema materializa as atividades aplicáveis ao plantão conforme periodicidade (ex.: diária aparece em todos os dias relevantes; item de quarta aparece só no plantão da quarta)
- Usuário do plantão vigente marca e desmarca itens com salvamento contínuo e finaliza o plantão
- Usuário do plantão seguinte revisa com salvamento contínuo e finaliza a revisão como correto ou com divergência registrada
- Checagens e confirmações ficam associadas ao usuário logado
- Alterações relevantes geram auditoria (quem, quando, o que)
- ADM acompanha o que foi checado e confirmado, checado e não confirmado, e o que não foi checado, além de divergências e status quando aplicável

**Fluxos alternativos e exceções**
- Item impossível de cumprir: exige motivo em texto; dispara tentativa síncrona de notificação (WhatsApp a definir tecnicamente)
- Divergência na revisão: permite concluir com divergência auditável; dispara tentativa síncrona de notificação (WhatsApp a definir tecnicamente)
- Antes da finalização da execução ou da revisão, checagens podem ser alteradas livremente com salvamento contínuo
- Após finalização do plantão na execução, edições ficam restritas ao ADM conforme regra de permissão
- Sem internet: fluxo operacional cai para acordo verbal; após retorno, ADM encerra com pendência "Sistema indisponível"

**Erros previstos**
- Usuário sem permissão
- Passagem já encerrada quando a ação exige estado aberto
- Tentativa de alterar registro sem permissão

**Prioridade:** média

---

#### FR-004 Listagem de plantões (relatório) com detalhe
Exibir lista de plantões (ex.: noturno 01/03, diurno 02/03) e, ao abrir, mostrar o que foi checado e revisado, respeitando regras de visibilidade por perfil.

**Fluxo principal**
- Usuário autorizado consulta a listagem por período ou navegação equivalente definida na implementação
- Usuário abre um plantão e visualiza detalhes permitidos ao seu perfil

**Fluxos alternativos e exceções**
- Hipótese: estados vazios retornam listagem vazia sem erro, salvo definir mensagem de UX no frontend

**Erros previstos**
- Usuário sem permissão

**Prioridade:** baixa

---

#### FR-005 Operações críticas do perfil Desenvolvedor
Permitir que o perfil Desenvolvedor gerencie parâmetros de sistema, exporte auditoria e use impersonação, com trilhas adequadas de segurança conforme implementação.

**Fluxo principal**
- Desenvolvedor autenticado acessa funções restritas
- Sistema registra auditoria dessas ações conforme política definida na implementação

**Fluxos alternativos e exceções**
- Hipótese: impersonação exige motivo e janela de tempo, se o time definir na implementação

**Erros previstos**
- Usuário sem permissão de Desenvolvedor

**Prioridade:** média

---

### Requisitos não funcionais

Performance
- Operações típicas de checklist (abrir, salvar checagem, concluir revisão) devem responder em até 1 segundo na rede da instituição na maior parte dos casos

Disponibilidade
- Serviço planejado para operação 24 horas por dia com meta de 99,5% de uptime mensal em produção

Segurança e autorização
- Autenticação via JWT; checagem de perfil por endpoint ou mecanismo equivalente centralizado com a mesma garantia
- Sem MFA na v1
- Mascarar senha e tokens em logs; restringir acesso aos logs ao perfil Desenvolvedor
- Auditoria para alterações sensíveis já previstas no fluxo funcional

Observabilidade
- Logs estruturados com tracing distribuído
- Em erro, registrar stack trace e dados de entrada com mascaramento de segredos
- Alertas quando o sistema estiver indisponível
- Rastrear processos mais lentos e identificar rotas com maior tempo de resposta

Confiabilidade e integridade de dados
- Salvamento incremental de checagens antes da finalização; finalização marca ponto de controle do fluxo
- PostgreSQL como fonte de verdade relacional para consistência transacional das operações críticas de registro

Compatibilidade e portabilidade
- Backend REST consumido por frontend separado; comunicação JSON com HTTPS obrigatório em produção (hipótese mínima de segurança em trânsito)
- Implantação em nuvem de mercado em container ou equivalente, conforme decisão de implementação

Compliance
- LGPD explicitamente fora do escopo da versão 1 no que tange requisitos formais adicionais; permanece risco operacional e reputacional no mundo real

Acessibilidade no frontend consumidor
- Não definida na v1 neste PRD; hipótese: definir alvo de acessibilidade quando o frontend for especificado (por exemplo critérios mínimos de contraste e navegação por teclado)

---

### Arquitetura e abordagem

Abordagem
- Sistema novo modularizado em backend REST e frontend, autenticação JWT, autorização por perfil, persistência relacional em PostgreSQL, deploy em nuvem. Processamento síncrono na v1. Gatilhos de notificação executados no fluxo da requisição, sem fila.

Componentes
- API REST (backend)
- PostgreSQL
- Frontend consumidor da API
- Serviço de observabilidade (logs, tracing, métricas) integrado ao backend
- Módulo de notificação com integração WhatsApp a definir

Integrações
- WhatsApp para notificações operacionais (provedor e modelo de API a definir; gatilhos já descritos no fluxo)

### Decisões e trade-offs

#### Decisão: JWT com autorização por perfil em cada endpoint
- **Justificativa:** modelo comum para API REST com frontend separado e controle fino por rota
- **Trade-off:** tokens precisam de política clara de expiração e revogação; comprometimento de token exige mitigação operacional

#### Decisão: PostgreSQL como banco relacional
- **Justificativa:** integridade referencial e transações para registros auditáveis e estados de plantão
- **Trade-off:** modelo de dados para periodicidades complexas pode exigir cuidado de modelagem e performance em consultas

#### Decisão: v1 síncrona sem filas e sem offline
- **Justificativa:** simplicidade e velocidade de entrega
- **Trade-off:** falhas em integrações externas impactam a resposta da API; queda de internet bloqueia o fluxo digital

#### Decisão: divergência permite concluir com registro auditável
- **Justificativa:** evita travar operação clínica administrativa enquanto preserva trilha para ADM mediar
- **Trade-off:** exige disciplina de leitura e ação do ADM para não virar "concluir sem resolver"

#### Decisão: logs com stack trace e entrada, com mascaramento de segredos
- **Justificativa:** acelerar diagnóstico em produção
- **Trade-off:** risco residual de dados sensíveis fora de senha e token se não houver política adicional de redação

#### Decisão: LGPD fora do escopo formal da v1
- **Justificativa:** reduzir escopo inicial
- **Trade-off:** risco legal e reputacional pode existir apesar do escopo declarado

---

### Dependências

#### Organizacional: ausência de bloqueios externos declarados
Nada além do time de desenvolvimento foi declarado como pré-requisito externo para a v1.

---

### Riscos e mitigação

#### Queda de internet impede passagem digital no horário
- **Probabilidade:** baixa
- **Impacto:** impossibilidade de concluir passagem de plantão no app até restabelecer conectividade, com risco operacional no período
- **Mitigação:**
  - Aceitar ausência de offline na v1 por decisão de escopo
  - Procedimento operacional de acordo verbal entre partes enquanto indisponível
  - Após retorno, ADM encerra plantão com pendência "Sistema indisponível"
- **Plano de contingência:** continuidade por acordo verbal como hoje e reconciliação no sistema quando a rede voltar

#### Vazamento de informações por logs ou acesso indevido a logs
- **Probabilidade:** baixa
- **Impacto:** exposição de dados de funcionários e dano reputacional
- **Mitigação:**
  - Mascarar senha e tokens em logs
  - Restringir acesso aos logs ao perfil Desenvolvedor
- **Plano de contingência:** comunicação interna para acionar resposta institucional ao incidente

---

### Critérios de aceitação
Checklist objetivo que define se a feature está pronta.

- ADM consegue cadastrar usuários
- ADM consegue cadastrar itens e distribuir tarefas (por plantão e por usuário) com periodicidade configurável
- O sistema exibe corretamente as atividades conforme periodicidade (diária em dias aplicáveis, dia da semana específico só no plantão correspondente, múltiplas vezes ao dia conforme regra, e equivalentes para semanal, quinzenal e mensal conforme modelado)
- Usuário de enfermagem consegue checar itens com salvamento contínuo e finalizar plantão
- Usuário de enfermagem consegue revisar com salvamento contínuo e finalizar revisão
- ADM consegue ver relatório de cada plantão com quem finalizou a execução e quem finalizou a revisão, e elementos adicionais de divergência conforme regras de visibilidade
- JWT obrigatório nas rotas protegidas e bloqueio consistente para perfil não autorizado
- Auditoria registrando quem alterou o quê e quando nos eventos definidos como auditáveis
- Testes unitários, integração API e banco, e contrato executados no pipeline acordado pelo time

---

### Testes e validação

Tipos de teste obrigatórios
- Testes unitários
- Testes de integração entre API e banco
- Testes de contrato (por exemplo alinhados a OpenAPI)

Estratégia de validação
- TDD nos módulos prioritários da v1: autenticação (prioridade alta), passagem de plantão com checklist e revisão (prioridade média), perfis e permissões (prioridade média), e extensão recomendada também à listagem (prioridade baixa) se o time adotar TDD em todo o MVP
