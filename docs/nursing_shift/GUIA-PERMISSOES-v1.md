### Guia de negócio: grupos de permissão do Arkham

Versão: 1.0
Data: 2026-07-27
Público-alvo deste guia: quem cadastra usuários e decide qual grupo de acesso atribuir (ex.: RH, administração, liderança)

Este documento explica, em linguagem não técnica, os grupos de acesso disponíveis no sistema e como escolher o grupo correto ao cadastrar uma nova pessoa. Para o detalhamento técnico (tabela de permissões por funcionalidade), veja [PRD-Arkham-MVP-v1.md](PRD-Arkham-MVP-v1.md), seção "Grupos de permissão e hierarquia".

---

### Os 5 grupos, em linguagem simples

**maintainer** — Time técnico do sistema
Acesso a absolutamente tudo, incluindo ferramentas internas de manutenção e diagnóstico que não existem para o dia a dia da instituição (ex.: investigar um erro, acessar registros técnicos, testar novas funcionalidades). Use este grupo **apenas** para quem desenvolve ou dá suporte técnico ao sistema.

**administrator** — Gestão da instituição
Acesso a tudo que envolve a operação da casa de repouso: enfermagem, financeiro, administrativo e as configurações gerais do sistema. É o grupo para quem toma decisões de gestão e precisa enxergar o quadro completo, mas não precisa (nem deve) mexer nas ferramentas técnicas internas.

**nursing_leaders** — Liderança de enfermagem
Acesso completo a tudo que é de enfermagem, incluindo a possibilidade de configurar como o checklist funciona (quais itens existem, com que frequência aparecem, para quem são atribuídos). Este grupo **não** vê informações financeiras nem administrativas da instituição. É o grupo para coordenadores e responsáveis técnicos de enfermagem.

**nursing_team** — Equipe de enfermagem
Acesso ao dia a dia operacional de enfermagem: marcar itens do checklist, revisar plantão anterior, registrar divergências. **Não** pode alterar como o checklist é configurado (isso é papel de nursing_leaders) nem ver dados financeiros/administrativos. É o grupo padrão para quem executa plantões.

**employer** — Colaborador com acesso básico
Acesso apenas a consultas e informações gerais, sem qualquer dado financeiro ou dado sensível de enfermagem (ex.: detalhes de saúde de pacientes, divergências de plantão). É o grupo mais restrito — use quando a pessoa precisa apenas de visibilidade básica sobre a operação, sem acesso a informação sensível.

---

### Como escolher o grupo certo

Pergunte, nesta ordem:

1. **A pessoa desenvolve ou dá suporte técnico ao sistema?**
   → Sim: **maintainer**

2. **A pessoa gerencia a instituição como um todo (inclui financeiro)?**
   → Sim: **administrator**

3. **A pessoa é responsável por enfermagem e precisa configurar como o checklist funciona (itens, frequência, atribuições)?**
   → Sim: **nursing_leaders**

4. **A pessoa executa plantões de enfermagem no dia a dia, sem precisar configurar nada?**
   → Sim: **nursing_team**

5. **Nenhuma das anteriores — a pessoa só precisa de uma visão geral básica, sem dados sensíveis ou financeiros?**
   → **employer**

Na dúvida entre dois grupos, **escolha sempre o mais restrito** e peça para elevar o acesso depois, se necessário — é mais seguro adicionar permissão do que remover depois de um acesso indevido já ter acontecido.

---

### O que cada grupo NÃO pode ver ou fazer

| Grupo | Não acessa |
| --- | --- |
| maintainer | (acesso total — nenhuma restrição) |
| administrator | Ferramentas técnicas internas de desenvolvimento/diagnóstico |
| nursing_leaders | Financeiro e configurações administrativas da instituição |
| nursing_team | Configuração do checklist (itens, periodicidade, atribuições) |
| employer | Financeiro e qualquer dado sensível de enfermagem |

---

### Perguntas frequentes

**Uma pessoa pode ter mais de um grupo?**
Este guia assume um grupo por pessoa, refletindo o papel principal dela na instituição. Se surgir um caso de acúmulo de função, trate como exceção e alinhe com o time técnico antes de cadastrar.

**E se eu errar o grupo ao cadastrar alguém?**
O grupo pode ser alterado depois pelo administrator ou maintainer. Prefira sempre começar com o grupo mais restrito possível (veja a seção anterior).

**Por que existe um grupo "employer" separado da enfermagem?**
Porque nem todo colaborador da casa de repouso trabalha com enfermagem, mas ainda pode precisar de alguma visibilidade básica sobre a operação (por exemplo, saber se um plantão foi concluído), sem que isso exija acesso a dados de saúde ou financeiros.
