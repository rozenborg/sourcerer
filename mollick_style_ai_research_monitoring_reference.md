# High-Signal AI Research Monitoring System: Reference Brief Inspired by Ethan Mollick's Scholarly Paper Filter

**Prepared for:** Executive Director, AI Integration, JPMorganChase  
**Primary use:** Reference material for an AI model / engineering team building a system that monitors new scholarly and policy research relevant to enterprise AI integration.  
**Snapshot date:** 2026-05-07  
**Status:** Working reference. This is an educated reconstruction of Ethan Mollick's public research-filtering pattern, not a claim about his private workflow.

---

## 0. How to use this document

This document is intended to be given to an AI system, research agent, or engineering team as a design reference. Its purpose is to help build a monitoring system that surfaces **high-signal AI research** as it appears, especially research relevant to a regulated financial institution.

The system should not merely monitor the keyword `AI`. It should monitor for research that could change decisions about:

- AI deployment in enterprise workflows.
- Human oversight and controls.
- Model risk, operational risk, compliance risk, privacy, security, and auditability.
- Employee training and AI literacy.
- Software engineering and SDLC transformation.
- Legal, compliance, policy, and knowledge-work augmentation.
- Team structure, organizational design, and productivity.
- AI agents and workflow automation.
- Financial-system stability and regulatory expectations.

The central design principle is:

> **Prefer papers that change what a smart organization should do next.**

This is the key lesson from the pattern of scholarly papers Ethan Mollick tends to reference publicly. The system should not optimize for volume, novelty alone, citation count alone, journal prestige alone, or leaderboard improvement alone. It should optimize for **decision relevance, evidence quality, task realism, boundary conditions, and implications for enterprise action**.

---

## 1. Core thesis: the Mollick-style research filter

Ethan Mollick's public writing suggests a consistent paper-selection pattern. He tends to surface papers that do at least one of the following:

1. **Measure AI changing real or realistic work.**  
   These papers study people doing recognizable tasks: writing, coding, consulting, law, product development, diagnosis, tutoring, idea generation, or customer support.

2. **Use credible comparisons.**  
   He strongly favors papers with controlled experiments, randomized trials, field experiments, baseline comparisons, or explicit human-vs-AI-vs-human+AI designs.

3. **Expose the boundary of AI usefulness.**  
   Many of the best papers do not just show that AI helps. They show where AI helps, where it hurts, and why humans misjudge that frontier.

4. **Show human-AI interaction effects.**  
   He is especially interested in cases where giving people AI does not automatically make them better. This includes overreliance, algorithmic aversion, prompt misuse, cognitive offloading, homogenization, and failure to calibrate trust.

5. **Generate an operating principle.**  
   Mollick tends to translate papers into memorable concepts: “secret cyborgs,” “jagged frontier,” “centaurs and cyborgs,” “skill leveler,” “falling asleep at the wheel,” “think first,” and “cybernetic teammate.”

6. **Suggest a managerial or organizational implication.**  
   The paper should affect how leaders design work, train people, govern AI, structure teams, or choose pilots.

7. **Reveal heterogeneity.**  
   A paper is more valuable if it shows who benefits and who does not: juniors vs. seniors, high performers vs. low performers, experts vs. novices, teams vs. individuals, inside-frontier vs. outside-frontier tasks.

8. **Create a testable enterprise hypothesis.**  
   The best papers imply internal experiments an organization can run.

### 1.1 The practical interpretation

A Mollick-style research monitor should answer:

> “Does this paper change a workflow, control, pilot, training program, governance policy, or executive belief?”

A paper that improves a benchmark by 3% may be technically important but low priority for enterprise AI integration. A paper showing that AI-assisted lawyers become faster but hallucinate in particular task classes is high priority. A paper showing that AI helps junior developers more than senior developers is high priority. A paper showing that employees silently use AI without telling management is high priority. A paper showing that AI-generated content becomes more homogeneous is high priority if the organization relies on independent analysis, diverse viewpoints, or second-line challenge.

---

## 2. System objective

Build a research monitoring system that continuously discovers, scores, summarizes, critiques, and routes new research relevant to enterprise AI integration at a global bank.

The system should create three primary outputs:

1. **Daily/near-real-time triage feed**  
   Short list of newly surfaced papers with relevance scores and one-sentence reason for inclusion.

2. **Weekly decision digest**  
   3–7 papers that merit human review, with decision cards and suggested routing.

3. **Monthly executive research memo**  
   Strategic synthesis: what research changed this month about deployment, controls, training, workflow design, agents, or governance.

The system should learn from feedback. It should become more like an internal “taste-trained” paper recommender than a generic AI-news search engine.

---

## 3. Design constraints for a regulated financial institution

Because the intended user is in AI Integration at JPMorganChase, the system must treat relevance differently from an academic or startup research feed.

### 3.1 High-value paper types

Prioritize papers that affect at least one of these areas:

| Enterprise area | Examples of relevant research findings |
|---|---|
| **Deployment strategy** | Which tasks benefit from GenAI, RAG, copilots, or agents? |
| **Controls and governance** | Where does human review fail? Where do audit trails matter? |
| **Model risk management** | How should model behavior, hallucination, drift, evaluation, and limitations be documented? |
| **Operational risk** | Does AI increase speed while reducing exception detection? |
| **Cybersecurity** | Prompt injection, data exfiltration, agent tool misuse, insecure code generation. |
| **Legal and compliance** | Legal reasoning, regulatory interpretation, citation hallucination, recordkeeping. |
| **Software engineering** | Developer productivity, code quality, secure SDLC, code review, testing. |
| **Workforce transformation** | Skills, training, deskilling, augmentation, role redesign. |
| **Organizational design** | Teams vs. individuals, expertise sharing, AI-enabled team structures. |
| **Financial stability and regulatory posture** | AI concentration risk, third-party dependencies, cloud/model provider risk, market correlations. |

### 3.2 Research that should be down-ranked

Down-rank papers that are:

- Pure leaderboard papers with no enterprise use case.
- Synthetic benchmark-only papers with no human or workflow relevance.
- Vendor-authored or vendor-funded reports without external validation.
- Prompt-demo papers with no baseline or rigorous evaluation.
- Papers that only test students or crowdworkers when the claimed implication is for experts, unless the limitation is clearly handled.
- Papers using obsolete models without a conceptual lesson that still generalizes.
- Papers whose results cannot be connected to a decision, control, or experiment.

### 3.3 Special rule for financial services

A paper does not have to be about banking to be relevant to banking. Some of the most useful evidence for a bank may come from medicine, law, education, software engineering, or management science because those domains provide stronger evidence on:

- Expert judgment.
- High-stakes decisions.
- Human overreliance.
- Documentation quality.
- Calibration of trust.
- Auditability.
- Text-heavy reasoning.
- Professional liability.
- Training transfer.

However, every cross-domain transfer must be explicitly labeled as an inference.

---

## 4. What “high signal” means in this system

A paper is high signal if it satisfies most of the following conditions.

### 4.1 Core signal criteria

| Criterion | Question the system should ask | High-signal indicator |
|---|---|---|
| **Task realism** | Is the task recognizable as actual professional work? | Real employees, professionals, or realistic simulations. |
| **Evidence quality** | Is there a credible comparison? | RCT, field experiment, preregistered study, strong baseline. |
| **Human-AI interaction** | Does the study compare human, AI, and human+AI? | Yes, especially with error/failure analysis. |
| **Boundary insight** | Does it show where AI fails or causes harm? | Inside/outside frontier, overreliance, hallucination, calibration failure. |
| **Heterogeneity** | Does it show who benefits more or less? | Skill, experience, role, task type, team structure. |
| **Enterprise actionability** | Could this change a pilot, workflow, control, or training plan? | Clear operating implication. |
| **Measurement breadth** | Does it measure quality/risk, not only speed? | Quality, accuracy, defects, hallucinations, confidence, diversity, satisfaction. |
| **Recency and model relevance** | Are the models and tools still relevant? | Current or conceptually durable. |
| **Communicability** | Can the result become an executive principle? | “AI is a skill leveler,” “inside/outside frontier,” etc. |

### 4.2 Gold / silver / bronze classification

| Tier | Definition | Default handling |
|---|---|---|
| **Gold** | Field experiment or RCT involving professionals, real or realistic work, clear baselines, and measurable enterprise implications. | Read closely, create decision card, route to stakeholders. |
| **Silver** | Lab or online experiment with realistic professional tasks, credible design, and plausible enterprise relevance. | Score and summarize; human review if above threshold. |
| **Bronze** | Benchmark, technical evaluation, survey, or observational study with some relevance. | Monitor, cluster, cite only with caveats. |
| **Watchlist** | Theoretical, conceptual, preprint, critique, or early claim. | Store and revisit if cited, replicated, or connected to high-priority lane. |
| **Ignore** | Hype, demos, vendor content, no baseline, no decision relevance. | Archive with reason to improve feedback loop. |

---

## 5. Source map: where to look

The system should monitor multiple source types. Do not rely on journals alone. Many Mollick-style papers first appear as working papers, preprints, SSRN papers, NBER papers, institutional working papers, conference proceedings, or blog-linked PDFs.

### 5.1 Discovery front doors

| Source | Why it matters | Implementation notes | Reference URL |
|---|---|---|---|
| **Semantic Scholar Research Feeds** | Adaptive recommender that learns from saved papers and folder feedback. Good for training the system on taste rather than keywords. | Create separate feeds per research lane. Use folders for seed papers and feedback. | https://www.semanticscholar.org/faq/what-are-research-feeds |
| **Semantic Scholar Academic Graph API** | Programmatic paper/author/citation metadata and recommendations. | Use for paper search, author alerts, citation graph, similar papers, and recommendation endpoints. | https://api.semanticscholar.org/api-docs/ |
| **SSRN** | Critical source for early business, law, economics, and management working papers. Many AI-at-work papers appear here before journal publication. | Monitor AI hub, Wharton, HBS, legal, labor, IO/productivity, randomized experiments streams. | https://www.ssrn.com/index.cfm/en/ai-gpt-3/ |
| **NBER** | High-quality working papers in economics, labor, productivity, organizational economics, and AI diffusion. | Monitor working papers and author pages. | https://www.nber.org/papers |
| **arXiv** | Fastest source for technical AI, agents, RAG, security, HCI-adjacent preprints, and evaluation work. | Filter aggressively; many papers will be low enterprise relevance. | https://info.arxiv.org/help/api/user-manual.html |
| **OpenAlex** | Open scholarly graph covering works, authors, institutions, topics, and sources. | Use for bibliographic graph enrichment and citation/network features. | https://developers.openalex.org/api-reference/introduction |
| **Crossref REST API** | DOI metadata and publication records. | Use for DOI normalization, journal metadata, publication dates. | https://www.crossref.org/documentation/retrieve-metadata/rest-api/ |
| **Google Scholar author pages** | Useful for manual author watchlists, but poor API support and scraping restrictions. | Use manually or via alerts where permitted; avoid brittle scraping. | https://scholar.google.com |
| **Institutional PDF pages** | HBS, MIT, Stanford, Microsoft, World Bank, BIS, FSB, regulators often host definitive versions. | Store canonical source URL and retrieved PDF hash. | varies |

### 5.2 Core research bodies and institutional hubs

| Body / hub | Why monitor it | Relevant lanes |
|---|---|---|
| **Harvard Business School AI Institute / former D^3** | Central to AI-at-work, field experiments, management, team design, and enterprise adoption research. | Knowledge work, organizational design, teams, productivity. |
| **Harvard Laboratory for Innovation Science (LISH)** | Field experiments, innovation science, crowdsourcing, human-AI collaboration. | Productivity, innovation, human-AI teaming. |
| **Wharton / Wharton Generative AI Lab** | Ethan Mollick's home ecosystem; AI in work, education, entrepreneurship, prompting, creativity. | Work, education, entrepreneurship, training. |
| **MIT Sloan / MIT Initiative on the Digital Economy** | Digital economy, productivity, software developers, labor, organizational economics. | Labor, productivity, SDLC, economics. |
| **Stanford Digital Economy Lab** | AI productivity, labor-market effects, adoption, firm impact. | Productivity, labor, diffusion. |
| **Stanford HAI** | Human-centered AI, policy, medicine, decision support, governance. | Human-AI judgment, governance, clinical analogs. |
| **Microsoft Research** | Developer productivity, software engineering, copilots, enterprise AI. | SDLC, developer tooling, agents, productivity. |
| **GitHub Research / GitHub Next** | Copilot and developer workflow research. | Coding, SDLC, developer adoption. |
| **World Bank Development Economics / EdTech** | High-quality RCTs on AI tutoring and training in real settings. | Training, education, AI literacy. |
| **BIS** | AI transformation in finance, financial stability, prudential policy, payments, asset management. | Finance, systemic risk, regulatory strategy. |
| **Financial Stability Board (FSB)** | AI vulnerabilities in finance, third-party concentration, cyber, model risk, governance. | Financial stability, controls, third-party risk. |
| **Bank of England / FCA** | AI and ML in financial services, surveys, supervisory posture. | Financial regulation, adoption, governance. |
| **Federal Reserve / FEDS Notes** | US financial-system research and policy analysis. | Finance, macro, risk, adoption. |
| **OCC / SEC / FINRA / FDIC** | Supervisory expectations, market integrity, model risk, operational risk. | Compliance, risk, regulatory. |
| **OECD / IZA / Brookings / IMF** | Labor-market, productivity, policy, and governance research. | Labor, policy, macro, regulation. |

### 5.3 Conferences and proceedings to monitor

| Venue | Why it matters | Filter rule |
|---|---|---|
| **ACM CHI** | Human-computer interaction, AI tools, workflow design, user studies. | Prioritize papers with field studies, professional users, cognitive impact, or evaluation methods. |
| **ACM CSCW** | Collaboration, teams, sociotechnical systems, workplace adoption. | Prioritize organizational AI and collaboration studies. |
| **ACM FAccT** | Fairness, accountability, transparency, governance, sociotechnical risk. | Prioritize papers on audits, governance, accountability, evaluation, model-risk analogs. |
| **AIES** | AI ethics and society. | Prioritize operationalizable governance work. |
| **ACL / EMNLP / NAACL** | NLP, LLM behavior, retrieval, evaluation, hallucination, agents. | Filter for evaluation, reliability, RAG, factuality, long-context, tool use. |
| **NeurIPS / ICML / ICLR** | Frontier AI methods, safety, agents, evaluations. | Do not ingest blindly; filter for applied evals, robustness, agent safety, security, enterprise relevance. |
| **ICSE / FSE / ASE / MSR** | Software engineering, developer productivity, code assistants, testing. | High priority for SDLC transformation. |
| **WWW / WebConf** | Information systems, web agents, search, retrieval, platform effects. | Watch for agents, retrieval, misinformation, data governance. |

### 5.4 Journals to monitor

| Domain | Journals / outlets |
|---|---|
| **Economics and productivity** | *Quarterly Journal of Economics*, *American Economic Review*, *AEJ: Applied Economics*, *Management Science*, NBER Working Papers. |
| **Management and organizations** | *Organization Science*, *Management Science*, *Administrative Science Quarterly*, *Strategic Management Journal*, *Information Systems Research*, *MIS Quarterly*. |
| **Human-AI interaction** | *Proceedings of the ACM on Human-Computer Interaction*, CHI proceedings, CSCW proceedings. |
| **Responsible AI / governance** | ACM FAccT proceedings, *AI & Society*, *Big Data & Society*. |
| **NLP and LLMs** | ACL Anthology, *Transactions of the ACL*, EMNLP/NAACL/ACL proceedings. |
| **Software engineering** | *IEEE Transactions on Software Engineering*, *ACM Transactions on Software Engineering and Methodology*, ICSE/FSE/ASE proceedings. |
| **Law and AI** | *Journal of Legal Education*, *Journal of Law and Empirical Analysis*, *Yale Journal of Law & Technology*, SSRN legal studies series. |
| **Medicine and decision support** | *JAMA Network Open*, *Nature Medicine*, *The Lancet Digital Health*, *NEJM AI*. Use for human-AI decision evidence, not direct banking claims. |
| **Finance and regulation** | BIS Working Papers, FSB reports, Bank of England/FCA reports, Federal Reserve working papers and FEDS Notes, SEC/FINRA/OCC publications. |

---

## 6. Research lanes to implement

The system should not have a single “AI papers” feed. It should maintain separate lanes with distinct seed papers, queries, filters, scoring weights, and routing logic.

### Lane 1: GenAI and knowledge-work field experiments

**Purpose:** Find papers that measure AI's effect on professional or semi-professional knowledge work.

**Include papers on:**

- Writing.
- Consulting.
- Customer support.
- Product development.
- Analyst work.
- Research work.
- Professional judgment.
- Human+AI vs. human-only performance.

**Preferred evidence:** RCTs, field experiments, natural experiments, preregistered studies.

**Seed examples:** Noy & Zhang; BCG jagged frontier; Brynjolfsson/Li/Raymond; P&G Cybernetic Teammate.

**Sample queries:**

```text
("generative AI" OR ChatGPT OR "large language model" OR LLM) AND
("field experiment" OR randomized OR RCT OR "controlled experiment") AND
("knowledge work" OR professionals OR productivity OR quality)
```

```text
("AI assistance" OR "AI augmentation" OR "human-AI collaboration") AND
(productivity OR quality OR "task performance") AND
(professionals OR workers OR employees)
```

**Routing:** AI integration leadership, business transformation, workforce strategy, HR learning, operations excellence.

---

### Lane 2: Developer productivity and SDLC transformation

**Purpose:** Surface evidence about coding assistants, software agents, code quality, secure coding, code review, testing, and developer workflow redesign.

**Include papers on:**

- GitHub Copilot / coding assistants.
- Software developer field experiments.
- Code generation quality.
- Test generation.
- Secure SDLC.
- Code review.
- Software engineering agents.
- Defect rates and maintainability.

**Preferred evidence:** Company-run RCTs, telemetry-backed studies, secure coding evaluations, developer behavior studies.

**Seed examples:** Peng et al. Copilot; Cui et al. three field experiments; ICSE/FSE studies on code LLMs.

**Sample queries:**

```text
("GitHub Copilot" OR "coding assistant" OR "AI pair programmer" OR "LLM code") AND
(productivity OR "completed tasks" OR "pull requests" OR "developer productivity" OR quality)
```

```text
("large language model" OR LLM OR "code generation") AND
(security OR vulnerability OR "unit test" OR "code review" OR maintainability)
```

**Routing:** Engineering enablement, developer experience, cybersecurity, SDLC governance, technology risk.

---

### Lane 3: Legal, compliance, RAG, and reasoning-heavy work

**Purpose:** Track AI performance in legal analysis, source-grounded reasoning, regulatory interpretation, citation accuracy, and RAG systems.

**Include papers on:**

- Legal reasoning with LLMs.
- RAG vs. non-RAG comparisons.
- Citation hallucination.
- Domain-specific legal tools.
- Contract review.
- Compliance interpretation.
- Audit evidence and source grounding.
- Reasoning models in legal tasks.

**Preferred evidence:** RCTs, task-specific evaluations, source accuracy measurement, hallucination/error analysis.

**Seed examples:** Choi & Schwarcz; Schwarcz et al. AI-Powered Lawyering.

**Sample queries:**

```text
("legal analysis" OR lawyering OR "legal reasoning" OR compliance OR regulation) AND
("large language model" OR ChatGPT OR "reasoning model" OR RAG OR "retrieval augmented generation")
```

```text
(RAG OR "retrieval augmented generation") AND
(hallucination OR citations OR "source grounding" OR "legal" OR compliance)
```

**Routing:** Legal, compliance, controls, audit, model risk, records management.

---

### Lane 4: Human oversight, overreliance, calibration, and failure modes

**Purpose:** Find research on when human+AI systems fail, especially because of overtrust, undertrust, weak prompting, automation bias, or lack of calibration.

**Include papers on:**

- Algorithmic aversion.
- Automation bias.
- Overreliance.
- Confidence calibration.
- Human review failure.
- “Falling asleep at the wheel.”
- AI-induced false confidence.
- Human-in-the-loop evaluation.
- Exception detection.

**Preferred evidence:** Experiments with high-stakes or expert decision tasks; studies measuring both performance and confidence.

**Seed examples:** Dell'Acqua HR recruiters; Goh et al. diagnostic reasoning; BCG outside-frontier task; older automation-bias literature.

**Sample queries:**

```text
("human-AI collaboration" OR "AI assistance" OR "human in the loop") AND
(overreliance OR "automation bias" OR calibration OR "algorithmic aversion" OR confidence)
```

```text
("large language model" OR LLM OR ChatGPT) AND
("human oversight" OR "human review" OR "AI errors" OR hallucination) AND
(experiment OR trial OR study)
```

**Routing:** Risk, compliance, operational controls, model risk, governance, training.

---

### Lane 5: Training, skill formation, education, and cognitive offloading

**Purpose:** Track research on how AI changes learning, skill acquisition, deskilling, training transfer, and cognitive effort.

**Include papers on:**

- AI tutors.
- Employee training.
- Prompting pedagogy.
- Cognitive offloading.
- Learning loss or learning gains.
- Skill leveling.
- Expertise formation.
- Junior employee development.
- “Think first, write first, meet first” design principles.

**Preferred evidence:** RCTs, classroom/field experiments, longitudinal studies, retention measures, transfer tests.

**Seed examples:** From Chalkboards to Chatbots; Turkey homework study; MIT Media Lab “Your Brain on ChatGPT” as a cautionary preprint; education prompt experiments.

**Sample queries:**

```text
("AI tutor" OR "LLM tutor" OR ChatGPT OR Copilot) AND
(learning OR training OR education OR "skill acquisition" OR "cognitive offloading") AND
(randomized OR experiment OR trial)
```

```text
("generative AI" OR ChatGPT) AND
("employee training" OR upskilling OR deskilling OR "skill formation" OR "learning outcomes")
```

**Routing:** AI literacy program, HR learning, workforce strategy, leadership training, adoption/change management.

---

### Lane 6: AI in finance, regulation, model risk, and systemic stability

**Purpose:** Monitor research and regulatory publications on AI adoption in finance, financial stability, prudential policy, third-party dependency, and governance.

**Include papers and reports on:**

- AI adoption in financial services.
- Financial stability implications.
- Third-party concentration and cloud/model provider dependency.
- Market correlation risk from common models/data.
- AI in payments, asset management, insurance, credit, trading, RegTech, SupTech.
- Model governance and model risk.
- Cyber risk.
- Operational resilience.

**Preferred sources:** BIS, FSB, Bank of England, FCA, Federal Reserve, OCC, SEC, FINRA, IMF, OECD, academic finance journals.

**Seed examples:** BIS “Intelligent financial system”; FSB AI financial stability report; BoE/FCA AI in UK financial services survey.

**Sample queries:**

```text
("artificial intelligence" OR "generative AI" OR "machine learning") AND
("financial stability" OR "model risk" OR "third-party" OR "operational resilience" OR "financial services")
```

```text
("AI" OR "large language model" OR "machine learning") AND
(bank OR banking OR "financial institution" OR payments OR trading OR "asset management") AND
(governance OR regulation OR supervision OR risk)
```

**Routing:** Model risk, operational risk, compliance, technology risk, third-party risk, regulatory affairs, cyber.

---

### Lane 7: Agents and enterprise workflow automation

**Purpose:** Track AI agents, tool use, workflow orchestration, task horizon, autonomous execution, and agent risk.

**Include papers on:**

- AI agents.
- Tool-use models.
- Web navigation.
- Long-horizon task completion.
- Agent benchmarks.
- Enterprise workflow agents.
- Agent evaluation harnesses.
- Safety, security, and containment.
- Human supervisory checkpoints.

**Preferred evidence:** End-to-end task evaluations, real-world task suites, failure taxonomies, security analyses, agent benchmark limitations.

**Sample queries:**

```text
("AI agent" OR "LLM agent" OR "agentic" OR "tool use" OR "web agent") AND
(evaluation OR benchmark OR "task completion" OR workflow OR enterprise)
```

```text
("LLM agent" OR "autonomous agent") AND
(security OR safety OR "prompt injection" OR "tool misuse" OR "human oversight")
```

**Routing:** AI platform, operations automation, technology risk, cyber, controls, business process owners.

---

### Lane 8: Creativity, innovation, and knowledge production

**Purpose:** Track research about AI's impact on idea generation, creativity, originality, homogenization, research productivity, and innovation workflows.

**Include papers on:**

- AI idea generation.
- Product innovation.
- Diversity of outputs.
- Scientific discovery.
- Research support.
- Strategy memos and analysis quality.
- Group brainstorming with AI.

**Preferred evidence:** Experiments measuring quality and diversity; professional or expert evaluations; comparisons of individual vs. group vs. AI.

**Seed examples:** Doshi & Hauser; Wharton idea-generation contest; P&G Cybernetic Teammate.

**Sample queries:**

```text
("generative AI" OR GPT-4 OR ChatGPT) AND
(creativity OR "idea generation" OR innovation OR "product development") AND
(diversity OR novelty OR quality OR experiment)
```

**Routing:** Strategy, innovation, product, research, transformation, leadership teams.

---

## 7. Author and researcher watchlist

The system should maintain author alerts for specific researchers, but it should not hard-code affiliations forever. Author affiliations and titles change. Resolve current author metadata dynamically through Semantic Scholar, OpenAlex, Crossref, institutional pages, or Google Scholar alerts where permitted.

### 7.1 AI, work, productivity, and organizations

| Researcher | Why monitor | Likely source ecosystems |
|---|---|---|
| **Ethan Mollick** | Public curator and researcher on AI at work, education, entrepreneurship, and practical adoption. | Wharton, One Useful Thing, SSRN, academic papers. |
| **Fabrizio Dell'Acqua** | Human-AI collaboration, BCG jagged frontier, HR overreliance, P&G teamwork. | HBS AI Institute, SSRN, HBS working papers. |
| **Karim Lakhani** | Innovation science, AI and organizations, field experiments. | HBS, LISH, D^3/HBS AI Institute, SSRN. |
| **Hila Lifshitz-Assaf** | Knowledge work, innovation, organizational transformation. | HBS/NYU ecosystems, SSRN. |
| **Katherine Kellogg** | AI in organizations, workplace implementation, sociotechnical change. | MIT Sloan, management journals. |
| **Raffaella Sadun** | Management, productivity, firm organization. | HBS, NBER, management/economics journals. |
| **Edward McFowland III** | AI and organizations, analytics, field experiments. | HBS/Harvard, management science. |
| **Charles Ayoubi** | AI and innovation/product development. | HBS AI Institute, SSRN. |
| **Lilach Mollick** | AI in education and prompting. | Wharton, education/AI resources. |
| **Christian Terwiesch** | Innovation, operations, idea generation with AI. | Wharton, SSRN. |
| **Lennart Meincke** | AI and creative idea generation. | Wharton/innovation research. |

### 7.2 Economics, productivity, labor, and firm adoption

| Researcher | Why monitor | Likely source ecosystems |
|---|---|---|
| **Erik Brynjolfsson** | AI productivity, digital economy, labor and firm-level adoption. | Stanford Digital Economy Lab, NBER. |
| **Danielle Li** | AI and worker productivity, economics of innovation. | MIT Sloan, NBER. |
| **Lindsey Raymond** | Generative AI at work field evidence. | NBER / economics. |
| **David Autor** | Labor-market implications of automation and AI. | MIT, NBER. |
| **Daron Acemoglu** | Automation, productivity, labor displacement. | MIT, NBER. |
| **Edward Felten** | AI exposure measurement, occupations and industries. | Princeton, arXiv, SSRN. |
| **Manav Raj** | AI exposure, labor, firms, startups. | Wharton, SSRN. |
| **Robert Seamans** | AI, labor, industries, strategy. | NYU Stern, SSRN. |
| **Zheyuan / Kevin Cui** | Software developer field experiments. | Princeton, SSRN. |
| **Mert Demirer** | AI productivity, field experiments, economics. | MIT Sloan, NBER. |
| **Sonia Jaffe** | Microsoft Research, software developer productivity. | Microsoft Research. |
| **Sida Peng** | GitHub Copilot and developer productivity. | Microsoft/GitHub, arXiv, SSRN. |
| **Tobias Salz** | Industrial organization, productivity, field experiments. | MIT, NBER. |

### 7.3 Legal, compliance, RAG, and professional reasoning

| Researcher | Why monitor | Likely source ecosystems |
|---|---|---|
| **Jonathan H. Choi** | Empirical legal AI studies. | SSRN, law journals. |
| **Daniel Schwarcz** | AI lawyering, legal analysis, RAG vs. reasoning models. | University of Minnesota, SSRN, law journals. |
| **J.J. Prescott** | Empirical legal studies, technology and legal systems. | University of Michigan, SSRN. |
| **Sam Manning** | Legal AI empirical work. | SSRN / legal AI. |
| **Beverly Rich** | Legal profession and AI. | Law/AI scholarship. |
| **Daniel Ho** | AI governance, legal/public-sector AI evaluation. | Stanford, policy/legal AI. |
| **Michael Livermore** | Legal analytics and AI governance. | Law journals, SSRN. |

### 7.4 Human-AI judgment, medicine, and decision support

| Researcher | Why monitor | Likely source ecosystems |
|---|---|---|
| **Ethan Goh** | Physician diagnostic reasoning with GPT-4. | JAMA, medRxiv, Stanford. |
| **Jonathan H. Chen** | Clinical AI, decision support, human-AI systems. | Stanford, JAMA, medical informatics. |
| **Adam Rodman** | Medical reasoning and AI. | Harvard/BIDMC, JAMA, medRxiv. |
| **Eric Horvitz** | Human-AI interaction, decision support, AI reliability. | Microsoft Research, Stanford HAI. |
| **Berkeley Dietvorst** | Algorithm aversion and human trust in algorithms. | Behavioral science journals. |
| **Cade Massey** | Algorithm aversion, judgment and decision-making. | Wharton / behavioral science. |
| **Joseph Simmons** | Judgment, experimental design, algorithm aversion. | Wharton / behavioral science. |

### 7.5 Education, training, and cognitive offloading

| Researcher | Why monitor | Likely source ecosystems |
|---|---|---|
| **Hamsa Bastani** | AI tutoring / learning experiments. | Wharton / operations / SSRN. |
| **Martín De Simone** | World Bank AI tutoring RCT in Nigeria. | World Bank. |
| **Federico Tiberti** | World Bank education RCTs. | World Bank. |
| **Maria Barron Rodriguez** | World Bank education and AI learning outcomes. | World Bank. |
| **Nataliya Kosmyna** | Cognitive effects of AI writing tools; “Your Brain on ChatGPT.” | MIT Media Lab, arXiv. |
| **Pattie Maes** | Human-computer interaction, cognitive augmentation. | MIT Media Lab. |

### 7.6 Finance, regulation, and systemic risk

| Researcher / body | Why monitor |
|---|---|
| **BIS authors on AI in finance** | AI and financial intermediation, payments, asset management, prudential policy. |
| **FSB AI reports** | Global financial stability vulnerabilities from AI adoption. |
| **Bank of England / FCA AI teams** | Financial-services AI surveys and regulatory posture. |
| **Federal Reserve FEDS authors** | US financial-system and macroeconomic research. |
| **OCC / SEC / FINRA / FDIC publications** | Supervisory, compliance, model risk, and market-integrity implications. |

---

## 8. Mollick-shared / Mollick-surfaced seed papers

The following seed papers are useful for training the recommender. Some are directly surfaced in Ethan Mollick's One Useful Thing posts. Others are close extensions in the same style and should be marked as “Mollick-aligned extension” if direct Mollick citation is not confirmed.

### 8.1 Known Mollick-publicly-surfaced papers from One Useful Thing posts

| Paper | Source URL | Mollick post / context | Why it is high signal | Bank-relevant implication |
|---|---|---|---|---|
| **Peng et al., “The Impact of AI on Developer Productivity: Evidence from GitHub Copilot”** | https://arxiv.org/abs/2302.06590 | “Secret Cyborgs: The Present Disruption in Three Papers” — https://www.oneusefulthing.org/p/secret-cyborgs-the-present-disruption | Controlled productivity evidence for coding assistance; concrete task completion metric. | Use as seed for SDLC productivity monitoring; look for speed-quality-security tradeoffs. |
| **Noy & Zhang, “Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence”** | Science: https://www.science.org/doi/10.1126/science.adh2586 ; SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4375283 | “Secret Cyborgs” and “Everyone is above average” — https://www.oneusefulthing.org/p/everyone-is-above-average | Preregistered experiment on professional writing tasks; shows speed and quality effects and reduced inequality. | Relevant to analyst memos, policy drafting, documentation, controls narratives, and review workflows. |
| **Felten, Raj & Seamans, “How Will Language Modelers like ChatGPT Affect Occupations and Industries?”** | arXiv: https://arxiv.org/abs/2303.01157 ; SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4375268 | “Secret Cyborgs” | Exposure mapping by occupation and industry. Useful for workforce strategy and prioritization. | Helps prioritize functions with high language-model exposure: legal, securities/investments, analysts, compliance-heavy work. |
| **Dell'Acqua et al., “Navigating the Jagged Technological Frontier”** | SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4573321 ; HBS: https://www.hbs.edu/faculty/Pages/item.aspx?num=64700 | “Centaurs and Cyborgs on the Jagged Frontier” — https://www.oneusefulthing.org/p/centaurs-and-cyborgs-on-the-jagged | Field experiment with BCG consultants; shows AI helps inside the frontier and can hurt outside it. | Foundational for controls design: do not assume AI assistance improves all professional tasks. Build frontier maps and escalation rules. |
| **Dell'Acqua, “Falling Asleep at the Wheel: Human/AI Collaboration in a Field Experiment on HR Recruiters”** | Author page / working paper reference: https://www.fabriziodellacqua.com/ ; HBS AI Institute discussion: https://d3.harvard.edu/is-ai-making-your-team-lazy/ | Referenced by Mollick in jagged frontier discussion and later writing. | Shows that high-quality AI can reduce human effort and independent judgment. | Critical for human-in-the-loop control design. Human review can fail if reviewers overtrust the system. |
| **Dell'Acqua et al., “The Cybernetic Teammate: A Field Experiment on Generative AI Reshaping Teamwork and Expertise”** | SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5188231 ; NBER: https://www.nber.org/papers/w33641 | Mollick post: https://www.oneusefulthing.org/p/the-cybernetic-teammate | Field experiment with P&G professionals; AI changes individual/team performance and expertise sharing. | Relevant to team design, staffing models, product development, and whether AI substitutes for or complements collaboration. |
| **Brynjolfsson, Li & Raymond, “Generative AI at Work”** | NBER: https://www.nber.org/papers/w31161 | “Everyone is above average” | Real deployment data with customer-support agents; shows productivity gains and larger gains for less-experienced workers. | Useful for operations, service, internal help desks, and junior-worker enablement. Monitor for quality and control effects. |
| **Choi & Schwarcz, “AI Assistance in Legal Analysis: An Empirical Study”** | SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4539836 | “Everyone is above average” | Empirical study of legal analysis with AI, including skill heterogeneity. | Directly relevant to legal, compliance, policy interpretation, and controls documentation. |
| **Doshi & Hauser, “Generative AI Enhances Creativity but Reduces the Diversity of Novel Content”** | Nature / Science Advances: https://www.science.org/doi/10.1126/sciadv.adn5290 ; arXiv: https://arxiv.org/abs/2312.00506 | “Everyone is above average”; “Against Brain Damage” | Shows individual creativity gains but output homogenization. | Critical for risk memos and strategy: AI may make analysis more fluent but less diverse and less independently generated. |
| **Goh et al., “Large Language Model Influence on Diagnostic Reasoning: A Randomized Clinical Trial”** | JAMA Network Open: https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825395 | “Getting started with AI: Good enough prompting” — https://www.oneusefulthing.org/p/getting-started-with-ai-good-enough | Expert-AI interaction study showing access to AI does not automatically improve expert performance. | Useful analogy for high-stakes expert work: bankers, lawyers, risk managers, and auditors may need training to benefit from AI. |
| **De Simone et al., “From Chalkboards to Chatbots: Evaluating the Impact of Generative AI on Learning Outcomes in Nigeria”** | World Bank: https://openknowledge.worldbank.org/entities/publication/15e1ff08-15ae-4f7a-b2a8-d146e6c113ee | “Against Brain Damage” — https://www.oneusefulthing.org/p/against-brain-damage | RCT of GPT-4 tutoring with teacher guidance; shows AI can help learning when designed as tutoring rather than answer outsourcing. | Relevant to AI literacy, internal training, and “AI as coach” programs. |
| **Kosmyna et al., “Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task”** | arXiv: https://arxiv.org/abs/2506.08872 | Discussed and contextualized in “Against Brain Damage” | Cautionary preprint on cognitive offloading and AI-written essays; should be treated carefully due to design limitations and preprint status. | Useful as a warning to design training around “think first” and not to outsource judgment prematurely. |

### 8.2 Mollick-aligned extension papers to seed the system

These papers fit the same high-signal pattern even if direct Mollick citation in One Useful Thing was not confirmed in this reference pass.

| Paper | Source URL | Why seed it | Bank-relevant implication |
|---|---|---|---|
| **Cui et al., “The Effects of Generative AI on High-Skilled Work: Evidence from Three Field Experiments with Software Developers”** | SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4945566 ; Microsoft Research: https://www.microsoft.com/en-us/research/publication/the-effects-of-generative-ai-on-high-skilled-work-evidence-from-three-field-experiments-with-software-developers/ | Multi-company field experiments with developers; directly relevant to SDLC transformation. | Use to guide coding-assistant adoption, measurement, and segment-specific enablement. |
| **Schwarcz et al., “AI-Powered Lawyering: AI Reasoning Models, Retrieval Augmented Generation, and the Future of Legal Practice”** | SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5162111 | RCT comparing legal RAG, reasoning model, and no-AI conditions. | Directly relevant to enterprise RAG, legal/compliance work, hallucination controls, and source grounding. |
| **Aldasoro et al., “Intelligent financial system: how AI is transforming finance”** | BIS: https://www.bis.org/publ/work1194.htm | Finance-specific research on AI across financial intermediation, insurance, asset management, payments, stability, and prudential policy. | High-value strategic context for AI integration in a bank. |
| **FSB, “The Financial Stability Implications of Artificial Intelligence”** | FSB: https://www.fsb.org/2024/11/the-financial-stability-implications-of-artificial-intelligence/ | Regulatory/systemic risk view; identifies finance-specific vulnerabilities. | Use for third-party, model-risk, governance, cyber, and financial-stability monitoring. |
| **Bank of England / FCA, “Artificial intelligence in UK financial services - 2024”** | https://www.bankofengland.co.uk/report/2024/artificial-intelligence-in-uk-financial-services-2024 | Survey of AI/ML adoption in financial services. | Useful for benchmarking adoption, governance, third-party dependency, and supervisory expectations. |

---

## 9. Paper scoring model

The system should calculate at least two scores:

1. **Mollick-likeness score** — Does the paper match the style of research Mollick tends to surface?
2. **JPMC actionability score** — Does the paper matter for AI integration at a regulated financial institution?

Do not collapse everything into a single opaque relevance score. Store sub-scores so humans can understand why a paper surfaced.

### 9.1 Mollick-likeness score

Score each paper 0–20.

| Feature | Points | Description |
|---|---:|---|
| Realistic work task | 0–3 | Task resembles actual knowledge work. |
| Human/AI comparison | 0–3 | Compares human, AI, and/or human+AI with meaningful baselines. |
| Evidence design | 0–3 | RCT, field experiment, preregistered, strong causal or quasi-causal design. |
| Boundary/failure insight | 0–3 | Identifies where AI helps vs. hurts, or shows overreliance/hallucination/calibration failure. |
| Heterogeneity | 0–2 | Shows differences by skill, role, task, expertise, team structure. |
| Managerial implication | 0–3 | Result can change workflow, training, controls, or organizational design. |
| Memorable operating principle | 0–2 | Result can be compressed into an executive concept. |
| Timeliness/model relevance | 0–1 | Uses models/tools or concepts still relevant. |

**Suggested thresholds:**

- 16–20: High-priority Mollick-style paper.
- 12–15: Strong candidate.
- 8–11: Monitor or route to lane specialist.
- 0–7: Low priority unless finance/regulatory critical.

### 9.2 JPMC actionability score

Score each paper 0–25.

| Feature | Points | Description |
|---|---:|---|
| Direct workflow relevance | 0–4 | Applies to bank workflows: engineering, risk, compliance, legal, operations, support, research, controls. |
| Risk/control implications | 0–4 | Impacts governance, oversight, audit, model risk, security, privacy, legal, or compliance. |
| Evidence strength | 0–4 | Strong empirical design, baselines, meaningful sample, robust measurement. |
| Decision impact | 0–4 | Could change pilot selection, deployment, policy, training, or funding. |
| Failure-mode clarity | 0–3 | Identifies specific failure modes or boundary conditions. |
| Implementation feasibility | 0–3 | Suggests internal experiment or operationalizable control. |
| Executive communicability | 0–2 | Can be translated into an executive briefing. |
| Recency/strategic timing | 0–1 | Timely for current AI roadmap. |

**Suggested thresholds:**

- 20–25: Route to leadership; create decision card.
- 15–19: Human review; include in weekly digest if capacity permits.
- 10–14: Store and cluster; revisit if reinforced by later evidence.
- 0–9: Ignore unless required for regulatory watch.

### 9.3 Penalties

Apply penalties explicitly and store them.

| Penalty | Points | Trigger |
|---|---:|---|
| Hype / unsupported claims | -1 to -4 | Claims exceed evidence. |
| No baseline | -1 to -3 | No human, AI, or pre/post comparison. |
| Toy task | -1 to -3 | Task does not resemble real work. |
| Obsolete model/tool | -1 to -2 | Model no longer representative and no durable concept. |
| Vendor marketing | -1 to -5 | Vendor-authored, no external validation, promotional framing. |
| Tiny sample / underpowered | -1 to -3 | Sample too small for claimed inference. |
| No failure analysis | -1 to -2 | Only reports upside. |
| Overgeneralization | -1 to -3 | Student/crowdworker results claimed for experts without caveat. |

### 9.4 Routing score overrides

Some papers should route even with lower scores:

- Regulatory body publications from BIS, FSB, BoE/FCA, Federal Reserve, OCC, SEC, FINRA, FDIC.
- Papers about prompt injection, data leakage, agent tool misuse, or AI cyber risks.
- Papers about legal hallucination, RAG failure, or source-grounding breakdown.
- Papers about model risk, auditability, explainability, third-party dependency, or operational resilience.
- Papers that directly study financial services, banking, trading, payments, asset management, credit, or compliance.

---

## 10. Data model for the research monitor

The system should store both raw metadata and human/AI judgments. Every AI-generated judgment must be traceable to source text.

### 10.1 Core `Paper` schema

```json
{
  "paper_id": "string - internal UUID",
  "canonical_title": "string",
  "normalized_title_hash": "string",
  "authors": [
    {
      "name": "string",
      "author_ids": {
        "semantic_scholar": "string|null",
        "openalex": "string|null",
        "orcid": "string|null",
        "google_scholar": "string|null"
      },
      "affiliations_at_publication": ["string"],
      "is_watchlist_author": true
    }
  ],
  "publication_date": "YYYY-MM-DD|null",
  "first_seen_date": "YYYY-MM-DD",
  "last_updated_date": "YYYY-MM-DD|null",
  "venue": "string|null",
  "source_type": "journal|conference|working_paper|preprint|policy_report|institutional_report|vendor_report|blog|unknown",
  "source_urls": [
    {
      "url": "string",
      "source_name": "string",
      "retrieved_at": "datetime",
      "is_canonical": true
    }
  ],
  "doi": "string|null",
  "ssrn_id": "string|null",
  "arxiv_id": "string|null",
  "nber_id": "string|null",
  "abstract": "string|null",
  "full_text_available": true,
  "pdf_hash": "string|null",
  "license": "string|null",
  "citation_count": {
    "semantic_scholar": 0,
    "openalex": 0,
    "crossref": 0
  },
  "related_seed_papers": ["paper_id"],
  "embedding_vector_id": "string|null",
  "research_lanes": ["string"],
  "tags": ["string"]
}
```

### 10.2 Evidence extraction schema

```json
{
  "paper_id": "string",
  "evidence_design": {
    "type": "RCT|field_experiment|lab_experiment|observational|benchmark|survey|review|theory|policy_report|unknown",
    "is_preregistered": true,
    "sample_size": "number|null",
    "population": "professionals|employees|students|crowdworkers|experts|models_only|mixed|unknown",
    "setting": "real_workplace|professional_simulation|lab|online|classroom|benchmark|unknown",
    "control_condition": "string|null",
    "treatment_conditions": ["string"],
    "baseline_types": ["human_only", "ai_only", "human_plus_ai", "pre_post", "other"]
  },
  "tasks_studied": [
    {
      "task_name": "string",
      "task_domain": "coding|writing|legal|finance|customer_support|medicine|education|consulting|product_development|other",
      "task_realism": "toy|lab|professional_simulation|real_workflow|unknown",
      "inside_ai_frontier": "yes|no|mixed|unknown"
    }
  ],
  "models_or_tools": [
    {
      "name": "string",
      "version": "string|null",
      "provider": "string|null",
      "access_mode": "chatbot|api|enterprise_tool|rag_tool|copilot|agent|unknown"
    }
  ],
  "outcomes": [
    {
      "metric": "speed|quality|accuracy|cost|productivity|hallucination|confidence|diversity|satisfaction|learning|risk_detection|other",
      "reported_effect": "string",
      "direction": "positive|negative|null|mixed",
      "effect_size": "string|null",
      "source_location": "page/section/table/figure if available"
    }
  ],
  "failure_modes": [
    {
      "failure_type": "hallucination|overreliance|algorithmic_aversion|homogenization|security|privacy|bias|calibration|deskilling|quality_degradation|other",
      "description": "string",
      "evidence_strength": "high|medium|low|speculative"
    }
  ],
  "limitations": ["string"],
  "replication_status": "replicated|partially_replicated|contradicted|not_yet_replicated|unknown"
}
```

### 10.3 Scoring and routing schema

```json
{
  "paper_id": "string",
  "mollick_likeness_score": {
    "total": 0,
    "subscores": {
      "task_realism": 0,
      "human_ai_comparison": 0,
      "evidence_design": 0,
      "boundary_insight": 0,
      "heterogeneity": 0,
      "managerial_implication": 0,
      "operating_principle": 0,
      "timeliness": 0
    },
    "penalties": [
      {"name": "string", "points": 0, "reason": "string"}
    ]
  },
  "jpmc_actionability_score": {
    "total": 0,
    "subscores": {
      "workflow_relevance": 0,
      "risk_control_implications": 0,
      "evidence_strength": 0,
      "decision_impact": 0,
      "failure_mode_clarity": 0,
      "implementation_feasibility": 0,
      "executive_communicability": 0,
      "recency": 0
    },
    "routing_override": false,
    "override_reason": "string|null"
  },
  "recommended_action": "ignore|store|monitor|human_review|decision_card|weekly_digest|exec_brief|risk_escalation|pilot_candidate",
  "recommended_routes": [
    "AI Integration",
    "Model Risk",
    "Operational Risk",
    "Compliance",
    "Legal",
    "Cybersecurity",
    "Engineering Enablement",
    "HR Learning",
    "Regulatory Affairs",
    "Business Owner"
  ],
  "confidence": "high|medium|low",
  "rationale": "string"
}
```

### 10.4 Decision card schema

```json
{
  "paper_id": "string",
  "decision_card_date": "YYYY-MM-DD",
  "one_sentence_claim": "string",
  "why_it_matters_for_jpmc": "string",
  "evidence_type": "string",
  "population_and_generalizability": "string",
  "task_realism": "string",
  "what_improved": ["string"],
  "what_worsened_or_might_worsen": ["string"],
  "controls_implication": ["string"],
  "training_implication": ["string"],
  "workflow_implication": ["string"],
  "model_risk_implication": ["string"],
  "recommended_internal_experiment": "string|null",
  "strongest_reason_to_act": "string",
  "strongest_reason_to_ignore": "string",
  "contradictory_or_limiting_evidence": ["string"],
  "confidence": "high|medium|low",
  "citations": [
    {
      "claim": "string",
      "source_url": "string",
      "source_location": "string|null"
    }
  ]
}
```

---

## 11. System architecture

### 11.1 Recommended pipeline

```text
[Source collectors]
      ↓
[Metadata normalization]
      ↓
[Deduplication / canonicalization]
      ↓
[Lane classification]
      ↓
[Embedding similarity to seed sets]
      ↓
[Rule-based filters and overrides]
      ↓
[Evidence extraction]
      ↓
[Scoring: Mollick-likeness + JPMC actionability]
      ↓
[Skeptical critique / limitations agent]
      ↓
[Decision card generation for high scorers]
      ↓
[Human review and feedback]
      ↓
[Feedback updates to seed sets, scoring weights, and routing]
```

### 11.2 Collector services

Implement separate collectors to avoid treating all sources as equivalent.

| Collector | Input | Output | Notes |
|---|---|---|---|
| `SemanticScholarCollector` | API queries, author IDs, seed papers, recommendations | Paper metadata, abstracts, citations, related papers | Main scholarly recommender and graph enrichment. |
| `SSRNCollector` | RSS/email/manual exports/search URLs | Working-paper metadata, abstracts, PDF links | Respect SSRN terms; prefer official feeds/export where available. |
| `NBERCollector` | NBER working-paper pages/RSS/search | Working-paper metadata and PDFs | High-value for economics/productivity. |
| `ArxivCollector` | arXiv API category/query feeds | Preprint metadata and PDFs | High volume; filter aggressively. |
| `OpenAlexCollector` | API works/authors/institutions | Metadata enrichment and citation graph | Good for open bibliographic graph. |
| `CrossrefCollector` | DOI lookup | DOI metadata and publication status | Helps identify journal versions of working papers. |
| `InstitutionalCollector` | HBS, MIT, Stanford, Microsoft, World Bank, BIS, FSB, BoE/FCA, regulators | Reports and working papers | Use site search, RSS, or curated watch pages. |
| `MollickPublicCollector` | One Useful Thing RSS/public posts, public LinkedIn if compliant | Paper mentions and themes | Treat as curation signal, not source of truth. |
| `ConferenceCollector` | CHI, CSCW, FAccT, ACL Anthology, ICSE/FSE/ASE, NeurIPS/ICML/ICLR proceedings | Proceedings metadata | Filter for lanes and task realism. |

### 11.3 Deduplication rules

Many papers appear as preprints, SSRN entries, NBER working papers, institutional PDFs, and later journal articles. The system must deduplicate.

Use the following hierarchy:

1. DOI exact match.
2. arXiv ID / SSRN ID / NBER ID exact match.
3. Normalized title match.
4. Normalized title + first author + year.
5. Embedding similarity + overlapping author list.
6. Human adjudication for uncertain duplicates.

Store all versions under one canonical paper record with version metadata:

```json
{
  "version_type": "preprint|working_paper|journal_article|revised_working_paper|policy_report",
  "version_date": "YYYY-MM-DD",
  "url": "string",
  "notes": "string"
}
```

### 11.4 Citation graph and seed similarity

For each new paper, compute:

- Direct citation to seed paper.
- Seed paper cites new paper. This is rare but useful for updated versions.
- Shared references with seed papers.
- Shared authors with seed papers.
- Shared institutions with high-signal hubs.
- Semantic similarity of abstract to lane seed corpus.
- Similarity to positive-feedback papers.
- Distance from known low-quality/hype clusters.

Do not over-weight citation count for new papers; they are too new to have citations.

### 11.5 Feedback loop

Human reviewers should be able to mark:

- `high_signal`
- `useful_but_not_urgent`
- `too_technical`
- `too_hypey`
- `not_bank_relevant`
- `good_for_controls`
- `good_for_training`
- `good_for_engineering`
- `good_for_exec_brief`
- `false_positive`
- `route_to_specialist`

The system should use these labels to update:

- Lane seed sets.
- Scoring weights.
- Query expansion terms.
- Author watchlist weights.
- Penalty rules.
- Digest preferences.

---

## 12. Prompt templates for evaluator agents

The system should use multiple specialist evaluator prompts rather than one generic summarizer.

### 12.1 Scout agent: first-pass triage

```text
You are a research scout for AI Integration at a regulated global bank.

Evaluate the paper below for high-signal relevance. Do not summarize at length.

Return:
1. One-sentence claim.
2. Research lane(s).
3. Evidence type.
4. Population studied.
5. Task realism: toy, lab, professional simulation, real workflow, or unclear.
6. Whether the paper compares human-only, AI-only, and human+AI conditions.
7. Why this might matter to a bank.
8. Main reason to ignore it.
9. Initial Mollick-likeness score from 0–20.
10. Initial JPMC actionability score from 0–25.
11. Recommended action: ignore, store, monitor, human review, decision card, weekly digest, risk escalation, or pilot candidate.

Be conservative. Do not infer more than the abstract supports. Separate evidence from speculation.
```

### 12.2 Methods reviewer agent

```text
Act as a skeptical methods reviewer.

Assess the strength of the paper's evidence.

Return:
1. Study design.
2. Sample size and population.
3. Control and treatment conditions.
4. Whether randomization/preregistration is present.
5. Outcome measures.
6. Whether outcomes measure quality/risk or only speed.
7. Internal validity concerns.
8. External validity concerns for a regulated bank.
9. Whether the authors overclaim.
10. What would need to be replicated before an enterprise should act.
11. Confidence rating: high, medium, low.

Use direct source citations or page/section references where available.
```

### 12.3 Enterprise relevance agent

```text
Act as an enterprise AI integration strategist at a regulated global financial institution.

For this paper, identify:
1. Which bank workflows this could affect.
2. Whether the finding applies to engineering, risk, compliance, legal, operations, service, HR learning, or executive decision-making.
3. What business decision the paper could change.
4. What internal pilot the paper suggests.
5. What control or governance change the paper suggests.
6. What training or adoption change the paper suggests.
7. Where cross-domain transfer is speculative.
8. Whether this belongs in an executive briefing.

Do not claim direct applicability unless the studied task is sufficiently similar.
```

### 12.4 Controls and risk agent

```text
Act as a model risk, operational risk, and controls reviewer.

Evaluate this paper for risk/control implications.

Return:
1. Failure modes identified.
2. Human oversight implications.
3. Auditability implications.
4. Privacy/data implications.
5. Cybersecurity implications.
6. Third-party/vendor implications.
7. Compliance/legal implications.
8. Model risk implications.
9. Monitoring or evaluation requirements.
10. Red-team or control tests suggested by the paper.
11. Whether the paper indicates a need for policy change.

Be specific. Avoid generic statements.
```

### 12.5 Contradiction and replication agent

```text
Find evidence that supports, limits, contradicts, or replicates this paper.

Return:
1. Direct replications, if any.
2. Failed or partial replications, if any.
3. Later papers using newer models/tools.
4. Methodological critiques.
5. Domain-specific limitations.
6. Whether the result is robust enough for enterprise action.
7. Confidence rating.

Separate verified evidence from speculation.
```

### 12.6 Executive briefing agent

```text
Convert this paper into an executive decision card.

Audience: senior leaders overseeing AI integration at a regulated global bank.

Return:
1. Title and citation.
2. One-sentence finding.
3. Why executives should care.
4. What decision this could change.
5. What risk this reveals.
6. What action we should consider.
7. What not to conclude.
8. Confidence level.
9. Suggested owner: AI Integration, Legal, Compliance, Model Risk, Cyber, Engineering, HR Learning, or Business Unit.

Keep it crisp but not simplistic. Make caveats explicit.
```

---

## 13. Decision-card template

Every high-priority paper should become a card like this.

```markdown
# Decision Card: [Paper Title]

**Date reviewed:** YYYY-MM-DD  
**Research lane:** [Lane]  
**Recommended action:** [Pilot / Monitor / Brief executives / Send to risk / Ignore]  
**Confidence:** [High / Medium / Low]

## One-sentence claim

[Claim]

## What the paper studied

- **Population:** [professionals/students/etc.]
- **Task:** [what they did]
- **AI/tool:** [model/tool]
- **Design:** [RCT/field experiment/etc.]
- **Comparison:** [human-only, AI-only, human+AI, etc.]

## Main finding

[Speed, quality, productivity, risk, learning, etc.]

## What improved

- [Finding]

## What worsened or could worsen

- [Failure mode]

## Why this matters for JPMorganChase

[Specific relevance to workflow, control, training, governance, or strategic decision.]

## What we should do

- **Pilot candidate:** [yes/no and why]
- **Control implication:** [specific]
- **Training implication:** [specific]
- **Policy implication:** [specific]

## Strongest reason to act

[Reason]

## Strongest reason to ignore or wait

[Reason]

## Follow-up research needed

[Replication, newer model, bank-specific experiment, etc.]

## Source links

- [Paper](URL)
- [Related Mollick post if applicable](URL)
```

---

## 14. Example decision cards for key seed papers

### 14.1 Navigating the Jagged Technological Frontier

**Paper:** Dell'Acqua et al., “Navigating the Jagged Technological Frontier: Field Experimental Evidence of the Effects of AI on Knowledge Worker Productivity and Quality.”  
**Source:** https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4573321  
**Mollick post:** https://www.oneusefulthing.org/p/centaurs-and-cyborgs-on-the-jagged

**One-sentence claim:** AI can substantially improve professional knowledge work on tasks inside its capability frontier, but can degrade performance when tasks sit outside that frontier and humans overtrust plausible AI output.

**Why this matters for a bank:** The result argues against blanket AI deployment. Every workflow needs a frontier map: which subtasks are safe for AI assistance, which require constrained support, and which require independent human analysis before AI is consulted.

**Controls implication:** Build task-level controls, not tool-level controls. Require escalation and verification for outside-frontier or high-stakes tasks.

**Training implication:** Teach employees to identify task classes, not just write prompts.

**Internal experiment candidate:** Select 5–8 banking workflows and classify subtasks into “AI helpful,” “AI risky,” and “AI prohibited without independent review.” Test speed, quality, error, and confidence by condition.

---

### 14.2 The Cybernetic Teammate

**Paper:** Dell'Acqua et al., “The Cybernetic Teammate: A Field Experiment on Generative AI Reshaping Teamwork and Expertise.”  
**Source:** https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5188231  
**Mollick post:** https://www.oneusefulthing.org/p/the-cybernetic-teammate

**One-sentence claim:** In a professional product-development setting, AI changed the performance relationship between individuals and teams and helped bridge functional expertise.

**Why this matters for a bank:** The paper suggests AI can change team design and expertise access, not just individual productivity. It may affect how cross-functional work is staffed and how expertise is distributed.

**Controls implication:** If AI lets individuals perform more team-like work, governance must ensure missing perspectives are still represented: risk, legal, compliance, cyber, operations, and customer impact.

**Training implication:** Teach AI as a teammate and facilitator, not only as a drafting tool.

**Internal experiment candidate:** Compare individual+AI, team-only, and team+AI conditions for a controlled internal innovation or process-redesign challenge.

---

### 14.3 Generative AI at Work

**Paper:** Brynjolfsson, Li & Raymond, “Generative AI at Work.”  
**Source:** https://www.nber.org/papers/w31161  
**Mollick context:** https://www.oneusefulthing.org/p/everyone-is-above-average

**One-sentence claim:** Generative AI increased productivity in a real customer-support environment, with larger gains for less-experienced or lower-performing workers.

**Why this matters for a bank:** The paper supports a “skill leveler” hypothesis for certain operations and service workflows.

**Controls implication:** Productivity gains should be measured alongside quality, compliance, customer outcome, and escalation accuracy.

**Training implication:** AI may be especially useful for onboarding and junior-worker enablement, but organizations must avoid hiding skill gaps that matter in edge cases.

**Internal experiment candidate:** Test AI assistance in internal support, operations, or knowledge-base response workflows with quality, escalation, and compliance measures.

---

### 14.4 AI Assistance in Legal Analysis

**Paper:** Choi & Schwarcz, “AI Assistance in Legal Analysis: An Empirical Study.”  
**Source:** https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4539836  
**Mollick context:** https://www.oneusefulthing.org/p/everyone-is-above-average

**One-sentence claim:** AI assistance can affect legal analysis performance, with effects varying by skill level and task.

**Why this matters for a bank:** Legal and compliance work share features with banking controls: dense text, high stakes, exceptions, precedent, and audit requirements.

**Controls implication:** AI-generated legal or regulatory analysis must be source-grounded, reviewed, and logged.

**Training implication:** Legal/compliance users need special training on citation verification, source grounding, and non-obvious failure modes.

**Internal experiment candidate:** Evaluate AI-assisted policy interpretation or regulatory-change analysis with domain experts and blinded quality reviewers.

---

### 14.5 Large Language Model Influence on Diagnostic Reasoning

**Paper:** Goh et al., “Large Language Model Influence on Diagnostic Reasoning: A Randomized Clinical Trial.”  
**Source:** https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825395  
**Mollick post:** https://www.oneusefulthing.org/p/getting-started-with-ai-good-enough

**One-sentence claim:** Giving experts access to a strong LLM did not automatically improve their performance, illustrating that AI capability does not translate directly into human+AI capability.

**Why this matters for a bank:** Expert users may fail to benefit from AI if they treat it like search, distrust it at the wrong times, overtrust it at the wrong times, or lack a good interaction model.

**Controls implication:** Human-in-the-loop is not a sufficient control by itself. The human must be trained, incentivized, and given workflows that preserve independent judgment.

**Training implication:** Move beyond generic prompting classes. Train role-specific AI collaboration, verification, and calibration.

**Internal experiment candidate:** In a high-expertise workflow, compare expert-only, AI-only, and expert+AI performance, including confidence and error detection.

---

## 15. Search and alert configuration examples

### 15.1 Semantic Scholar folder structure

Create separate folders and turn on research feeds for each:

```text
01_GenAI_Knowledge_Work_Field_Experiments
02_GenAI_Developer_Productivity_SDLC
03_GenAI_Legal_RAG_Reasoning
04_GenAI_Human_Oversight_Overreliance
05_GenAI_Training_Skill_Formation
06_AI_Finance_Risk_Regulation
07_Agentic_Workflow_Automation
08_AI_Creativity_Innovation_Knowledge_Production
09_Methods_Evaluation_Reliability
10_Contradictions_Null_Results_Critiques
```

Each folder should contain seed papers and should be updated with accepted/rejected recommendations.

### 15.2 Query templates by source

#### SSRN

```text
"generative AI" "field experiment" productivity
"large language model" "knowledge work" randomized
"ChatGPT" "legal analysis" empirical
"retrieval augmented generation" legal hallucination
"AI assistance" professionals productivity quality
"human AI collaboration" overreliance experiment
"GitHub Copilot" productivity field experiment
"generative AI" software developers productivity
"AI" "financial stability" "model risk"
```

#### NBER

```text
"generative AI" productivity
"artificial intelligence" labor productivity
"AI" workers field experiment
"AI" firm adoption
"AI" software developers
"generative AI" customer support
"AI" middle class jobs
```

#### arXiv

```text
cat:cs.CL AND ("retrieval augmented generation" OR RAG) AND (hallucination OR factuality OR citation)
cat:cs.SE AND ("large language model" OR "coding assistant" OR "software agent")
cat:cs.CR AND ("prompt injection" OR "LLM agent" OR "data exfiltration")
cat:cs.HC AND ("human-AI collaboration" OR "AI assistance" OR overreliance)
cat:cs.AI AND ("LLM agent" OR "tool use" OR "web agent") AND evaluation
```

#### Regulatory/policy search

```text
site:bis.org artificial intelligence finance financial stability
site:fsb.org artificial intelligence financial sector vulnerabilities
site:bankofengland.co.uk artificial intelligence financial services machine learning survey
site:fca.org.uk artificial intelligence machine learning financial services
site:federalreserve.gov artificial intelligence financial services model risk
site:occ.gov artificial intelligence model risk banking
site:sec.gov artificial intelligence market risk compliance
site:finra.org artificial intelligence supervision compliance
```

---

## 16. Ranking logic

### 16.1 Initial ranking formula

The system can start with this weighted score:

```text
final_priority_score =
  0.35 * normalized_jpmc_actionability_score
+ 0.25 * normalized_mollick_likeness_score
+ 0.15 * evidence_strength_score
+ 0.10 * seed_similarity_score
+ 0.05 * author_watchlist_score
+ 0.05 * recency_score
+ 0.05 * regulatory_or_risk_override_score
- penalties
```

Where:

- `normalized_jpmc_actionability_score` = JPMC score / 25.
- `normalized_mollick_likeness_score` = Mollick score / 20.
- `evidence_strength_score` should independently measure design quality.
- `seed_similarity_score` should come from abstract/full-text embedding similarity to accepted seed papers.
- `author_watchlist_score` should be positive but not decisive.
- `recency_score` should be high for very new papers but should not swamp evidence quality.
- `regulatory_or_risk_override_score` should force review of finance/regulatory/cyber/model-risk items.

### 16.2 Evidence strength score

```text
field RCT with professionals: 1.00
field experiment with employees: 0.90
preregistered lab experiment with realistic tasks: 0.75
observational deployment study with credible controls: 0.70
large survey with strong methods: 0.55
benchmark with realistic eval: 0.45
technical benchmark only: 0.30
conceptual/theory paper: 0.25
vendor report without independent validation: 0.10
```

### 16.3 Task realism score

```text
real workflow, real employees: 1.00
professional simulation with domain experts: 0.85
professional simulation with students/crowdworkers: 0.60
lab task with plausible analog: 0.45
synthetic benchmark: 0.25
toy prompt/demo: 0.10
```

### 16.4 Failure-mode bonus

Add a bonus if the paper explicitly studies failures:

```text
+0.15 if the paper measures hallucinations, errors, overreliance, calibration, security, bias, or quality degradation.
+0.10 if it compares inside-frontier and outside-frontier tasks.
+0.10 if it measures human confidence or trust.
+0.10 if it identifies controls or mitigations.
```

---

## 17. Alert routing rules

### 17.1 Default routing by lane

| Lane | Primary recipients | Secondary recipients |
|---|---|---|
| Knowledge work field experiments | AI Integration, business transformation | HR learning, operations, strategy |
| Developer productivity / SDLC | Engineering enablement, technology leadership | Cyber, technology risk, SDLC governance |
| Legal / RAG / reasoning | Legal, compliance | Model risk, audit, records management |
| Human oversight / overreliance | Model risk, operational risk, compliance | HR learning, AI Integration |
| Training / skill formation | HR learning, AI literacy leads | AI Integration, workforce strategy |
| Finance / regulation / systemic risk | Regulatory affairs, risk, model risk | AI Integration, third-party risk, cyber |
| Agents / workflow automation | AI platform, operations automation | Cyber, model risk, controls |
| Creativity / innovation | Strategy, innovation, product | Risk, AI Integration |

### 17.2 Alert levels

| Level | Trigger | Output |
|---|---|---|
| **Level 0: Archive** | Low score, no routing override | Store metadata only. |
| **Level 1: Monitor** | Moderate score or weak evidence but relevant topic | Add to digest backlog. |
| **Level 2: Human review** | High score, relevant lane | Generate scout summary and methods critique. |
| **Level 3: Decision card** | High actionability or risk/control relevance | Generate full decision card and route to owner. |
| **Level 4: Executive brief** | Strategic implication, strong evidence, or major regulatory relevance | Include in weekly/monthly executive memo. |
| **Level 5: Risk escalation** | Material cyber, compliance, model risk, legal, third-party, or regulatory concern | Route immediately to risk/control stakeholders. |

---

## 18. Digest formats

### 18.1 Daily triage feed

```markdown
# AI Research Triage Feed — YYYY-MM-DD

## Top items

1. **[Title]** — [Score]
   - Lane: [Lane]
   - Why surfaced: [one sentence]
   - Evidence: [RCT/field experiment/etc.]
   - Action: [monitor/human review/etc.]

## Risk/control watch

- [Title] — [why relevant]

## Engineering/SDLC watch

- [Title] — [why relevant]

## Regulatory watch

- [Title/report] — [why relevant]
```

### 18.2 Weekly decision digest

```markdown
# Weekly AI Research Decision Digest — Week of YYYY-MM-DD

## Executive takeaways

1. [Takeaway]
2. [Takeaway]
3. [Takeaway]

## Papers requiring action

### [Paper Title]
- Claim:
- Evidence:
- Why it matters:
- Recommended owner:
- Suggested action:

## Papers to monitor

[Short list]

## Contradictions / cautionary findings

[Short list]

## Recommended internal experiments

[1–3 experiments]
```

### 18.3 Monthly executive memo

```markdown
# What AI Research Changed This Month — Month YYYY

## Bottom line

[3–5 sentence synthesis]

## Deployment implications

[What changed about where to deploy AI]

## Controls and risk implications

[What changed about governance, review, monitoring]

## Training and workforce implications

[What changed about AI literacy and role design]

## Software engineering implications

[What changed about developer tooling and SDLC]

## Regulatory and financial-services implications

[What changed in regulatory/systemic-risk context]

## Recommended actions

1. [Action]
2. [Action]
3. [Action]

## Appendix: scored papers

[Table]
```

---

## 19. Governance, reliability, and factuality requirements

### 19.1 Claim discipline

Every generated summary must separate:

1. **What the paper actually found.**
2. **What the authors claimed.**
3. **What the system infers for JPMorganChase.**
4. **What remains speculative.**

Never blur these categories.

### 19.2 Citation requirements

For each decision card, include source links and, where possible, page/section/table references for:

- Main effect size.
- Study population.
- Task description.
- Treatment/control conditions.
- Failure modes.
- Limitations.
- Funding or conflicts.

### 19.3 Do not overclaim from abstracts

If only the abstract is available, the system must mark:

```text
full_text_reviewed: false
confidence: low_or_medium
```

and avoid detailed claims about methods beyond what the abstract states.

### 19.4 Version control

When a working paper becomes a journal article, the system should:

- Link both versions.
- Compare abstract/results for changes.
- Update citation.
- Preserve prior decision card with version note.
- Re-score if findings changed.

### 19.5 Conflict and funding extraction

The system should extract:

- Funding source.
- Corporate partner involvement.
- Whether company had control over data or results.
- Author disclosures.
- Tool/vendor relationships.

This is especially important for vendor tools, legal AI products, financial-services applications, and enterprise productivity claims.

---

## 20. Anti-patterns to avoid

The system should explicitly avoid these failure modes:

1. **Journal prestige bias.**  
   Important AI-at-work papers may appear first as working papers or preprints.

2. **Benchmark addiction.**  
   Benchmark improvements are not automatically enterprise-relevant.

3. **Novelty chasing.**  
   A new paper is not high signal merely because it is new.

4. **Citation-count bias.**  
   New high-signal papers often have low citation counts at first.

5. **Vendor amplification.**  
   Vendor white papers should not be treated like independent evidence.

6. **Ignoring null results.**  
   Papers showing no improvement from AI can be more valuable than positive studies.

7. **Ignoring failure modes.**  
   Speed gains without quality/risk measurement should be treated as incomplete evidence.

8. **Overgeneralizing from students.**  
   Student studies can be useful, but the system must caveat transfer to expert work.

9. **Overtrusting AI summaries.**  
   The monitor itself must not hallucinate metrics, authors, or findings.

10. **Assuming human-in-the-loop is sufficient.**  
   Human oversight can fail through overreliance, fatigue, incentives, or weak training.

---

## 21. Internal experiment suggestions generated by this research pattern

The monitor should not only surface papers. It should generate experiment ideas.

### 21.1 Frontier mapping experiment

**Inspired by:** BCG jagged frontier paper.  
**Question:** Which internal workflows are inside vs. outside the current AI frontier?

**Design:**

- Select tasks from risk, compliance, legal, operations, engineering, and analyst work.
- Randomize employees to human-only, AI-assisted, and AI-assisted-with-verification conditions.
- Measure speed, quality, error type, confidence, and reviewer agreement.
- Build a frontier map by task class.

### 21.2 Human oversight calibration experiment

**Inspired by:** Falling Asleep at the Wheel; diagnostic reasoning study.  
**Question:** When does AI make reviewers less careful?

**Design:**

- Give reviewers outputs from AI tools with varying accuracy levels.
- Measure time spent, error detection, confidence, and independent reasoning.
- Test interventions: independent answer first, forced evidence citation, adversarial checklist, confidence calibration.

### 21.3 RAG vs. reasoning model experiment

**Inspired by:** AI-Powered Lawyering.  
**Question:** For compliance/legal/policy tasks, when is source-grounded RAG better than a general reasoning model?

**Design:**

- Compare domain RAG, reasoning model, general chatbot, and no-AI baseline.
- Use tasks involving policy interpretation, regulatory mapping, and exception analysis.
- Measure factuality, citation accuracy, analytical depth, time, and hallucinations.

### 21.4 Developer productivity and code quality experiment

**Inspired by:** Copilot and high-skilled software developer field experiments.  
**Question:** Does AI coding assistance improve throughput without increasing defects or security issues?

**Design:**

- Randomized or staggered rollout of coding assistant features.
- Measure completed tasks, cycle time, pull-request quality, test coverage, vulnerabilities, review burden, and rework.

### 21.5 AI as training coach experiment

**Inspired by:** World Bank tutoring RCT and education studies.  
**Question:** Can AI improve AI literacy and role-specific learning when used as tutor rather than answer engine?

**Design:**

- Compare standard training, AI tutor, AI answer assistant, and blended instructor+AI tutor.
- Measure learning, retention, transfer to work tasks, confidence calibration, and misuse.

### 21.6 Team design experiment

**Inspired by:** Cybernetic Teammate.  
**Question:** Does AI change the value of cross-functional teams?

**Design:**

- Compare individual-only, individual+AI, team-only, and team+AI conditions.
- Use realistic business process redesign or product strategy tasks.
- Measure quality, diversity of ideas, stakeholder coverage, speed, and participant experience.

---

## 22. Suggested initial seed set by lane

### 22.1 Knowledge work field experiments

- Dell'Acqua et al., “Navigating the Jagged Technological Frontier.”
- Dell'Acqua et al., “The Cybernetic Teammate.”
- Noy & Zhang, “Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence.”
- Brynjolfsson, Li & Raymond, “Generative AI at Work.”
- Doshi & Hauser, “Generative AI Enhances Creativity but Reduces the Diversity of Novel Content.”

### 22.2 Developer productivity / SDLC

- Peng et al., “The Impact of AI on Developer Productivity: Evidence from GitHub Copilot.”
- Cui et al., “The Effects of Generative AI on High-Skilled Work: Evidence from Three Field Experiments with Software Developers.”
- Add current ICSE/FSE/ASE papers on code generation, testing, security, and maintainability.

### 22.3 Legal / compliance / RAG

- Choi & Schwarcz, “AI Assistance in Legal Analysis.”
- Schwarcz et al., “AI-Powered Lawyering.”
- Add current papers on legal hallucination, source grounding, RAG evaluation, and citation verification.

### 22.4 Human oversight / overreliance

- Dell'Acqua, “Falling Asleep at the Wheel.”
- Goh et al., “Large Language Model Influence on Diagnostic Reasoning.”
- BCG jagged frontier outside-frontier task.
- Dietvorst, Simmons & Massey, “Algorithm Aversion” literature as older foundation.

### 22.5 Training / skills

- De Simone et al., “From Chalkboards to Chatbots.”
- Kosmyna et al., “Your Brain on ChatGPT.”
- Hamsa Bastani / education AI tutor studies.
- Wharton prompt and AI tutor resources.

### 22.6 Finance / regulation

- Aldasoro et al., “Intelligent financial system: how AI is transforming finance.”
- FSB, “The Financial Stability Implications of Artificial Intelligence.”
- FSB, “Monitoring Adoption of Artificial Intelligence and Related Vulnerabilities in the Financial Sector.”
- Bank of England / FCA, “Artificial intelligence in UK financial services - 2024.”
- Federal Reserve, OCC, SEC, FINRA AI publications as they appear.

---

## 23. Example YAML configuration

```yaml
system_name: ai_research_monitor
snapshot_date: 2026-05-07
objective: >
  Surface high-signal scholarly and policy research relevant to AI integration,
  controls, training, workflow design, and governance at a regulated global bank.

lanes:
  genai_knowledge_work:
    description: AI effects on professional knowledge work productivity and quality.
    priority: high
    seed_papers:
      - title: Navigating the Jagged Technological Frontier
        url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4573321
      - title: The Cybernetic Teammate
        url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5188231
      - title: Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence
        url: https://www.science.org/doi/10.1126/science.adh2586
      - title: Generative AI at Work
        url: https://www.nber.org/papers/w31161
    query_terms:
      - generative AI field experiment productivity knowledge work
      - ChatGPT professionals productivity quality randomized
      - human-AI collaboration knowledge workers experiment
    route_to:
      - AI Integration
      - Business Transformation
      - HR Learning

  developer_productivity_sdlc:
    description: AI coding assistants, developer productivity, software agents, secure SDLC.
    priority: high
    seed_papers:
      - title: The Impact of AI on Developer Productivity
        url: https://arxiv.org/abs/2302.06590
      - title: The Effects of Generative AI on High-Skilled Work
        url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4945566
    query_terms:
      - GitHub Copilot productivity field experiment
      - coding assistant developer productivity code quality
      - LLM code generation security vulnerability testing
    route_to:
      - Engineering Enablement
      - Cybersecurity
      - Technology Risk

  legal_rag_reasoning:
    description: Legal/compliance reasoning, RAG, hallucination, source grounding.
    priority: high
    seed_papers:
      - title: AI Assistance in Legal Analysis
        url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4539836
      - title: AI-Powered Lawyering
        url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5162111
    query_terms:
      - legal analysis LLM RAG hallucination
      - retrieval augmented generation legal reasoning citations
      - AI lawyering reasoning model empirical study
    route_to:
      - Legal
      - Compliance
      - Model Risk
      - Audit

  human_oversight_overreliance:
    description: Human-in-the-loop failure, automation bias, overreliance, calibration.
    priority: high
    seed_papers:
      - title: Falling Asleep at the Wheel
        url: https://www.fabriziodellacqua.com/
      - title: Large Language Model Influence on Diagnostic Reasoning
        url: https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825395
    query_terms:
      - human AI collaboration overreliance automation bias calibration
      - LLM human oversight confidence error detection
      - algorithmic aversion generative AI experiment
    route_to:
      - Model Risk
      - Operational Risk
      - Compliance
      - AI Integration

  training_skill_formation:
    description: AI tutoring, employee training, cognitive offloading, skill formation.
    priority: medium_high
    seed_papers:
      - title: From Chalkboards to Chatbots
        url: https://openknowledge.worldbank.org/entities/publication/15e1ff08-15ae-4f7a-b2a8-d146e6c113ee
      - title: Your Brain on ChatGPT
        url: https://arxiv.org/abs/2506.08872
    query_terms:
      - AI tutor randomized learning outcomes GPT-4
      - ChatGPT cognitive offloading learning experiment
      - generative AI employee training skill acquisition
    route_to:
      - HR Learning
      - AI Literacy
      - Workforce Strategy

  finance_risk_regulation:
    description: AI in finance, regulation, financial stability, model risk.
    priority: high
    seed_papers:
      - title: Intelligent financial system how AI is transforming finance
        url: https://www.bis.org/publ/work1194.htm
      - title: The Financial Stability Implications of Artificial Intelligence
        url: https://www.fsb.org/2024/11/the-financial-stability-implications-of-artificial-intelligence/
      - title: Artificial intelligence in UK financial services - 2024
        url: https://www.bankofengland.co.uk/report/2024/artificial-intelligence-in-uk-financial-services-2024
    query_terms:
      - artificial intelligence financial stability model risk governance
      - AI financial services third party dependencies cyber risk
      - generative AI banking regulation supervision
    route_to:
      - Regulatory Affairs
      - Model Risk
      - Operational Risk
      - Third Party Risk
      - Cybersecurity
```

---

## 24. Evaluation metrics for the monitoring system itself

The system should be evaluated like a recommender and analyst-support tool.

### 24.1 Precision metrics

- Percentage of surfaced papers that human reviewers mark `high_signal`.
- Percentage of weekly digest papers that lead to a decision, pilot, policy discussion, or stakeholder route.
- False-positive rate by source and lane.
- False-positive rate for arXiv technical papers.
- False-positive rate for vendor reports.

### 24.2 Recall metrics

- Did the system capture papers later surfaced by trusted curators such as Mollick, HBS AI Institute, NBER, BIS, FSB, or major conferences?
- Did the system capture newly published versions of existing working papers?
- Did the system catch regulatory reports within target time window?

### 24.3 Timeliness metrics

- Time from publication/first availability to ingestion.
- Time from ingestion to triage score.
- Time from high score to human review.
- Time from regulatory publication to risk stakeholder alert.

### 24.4 Usefulness metrics

- Number of internal pilots inspired by research.
- Number of control changes influenced by research.
- Number of training updates influenced by research.
- Number of executive memos citing research.
- Stakeholder satisfaction with weekly digest.

### 24.5 Factuality metrics

- Percentage of generated claims supported by source citations.
- Number of hallucinated metrics/authors/titles found in review.
- Number of papers misclassified by evidence design.
- Number of overgeneralization errors.

---

## 25. Minimum viable product

### 25.1 MVP scope

Start with six lanes:

1. Knowledge-work field experiments.
2. Developer productivity / SDLC.
3. Legal / RAG / reasoning.
4. Human oversight / overreliance.
5. Training / skill formation.
6. Finance / regulation.

Start with these sources:

- Semantic Scholar API + Research Feeds.
- SSRN monitoring.
- NBER working papers.
- arXiv API for selected categories.
- BIS / FSB / BoE-FCA / Federal Reserve / OCC / SEC / FINRA watch pages.
- One Useful Thing public posts as a curation signal.

### 25.2 MVP output

For each surfaced paper:

- Title.
- Authors.
- Source URL.
- Date.
- Lane(s).
- Abstract.
- Evidence type.
- Population.
- Task realism.
- Mollick-likeness score.
- JPMC actionability score.
- Recommended action.
- One-sentence reason.
- Caveat.

### 25.3 MVP human review workflow

1. System generates daily triage.
2. Human reviewer marks each item: high signal / useful / ignore / wrong lane / route.
3. System updates feedback model weekly.
4. Top 3–7 papers become weekly digest.
5. Top 1–3 papers become decision cards.

---

## 26. What the system should learn over time

The system should learn that “AI research relevance” for a bank is not the same as “AI technical novelty.”

High-scoring future papers will often have words like:

- field experiment
- randomized
- professionals
- workers
- productivity
- quality
- overreliance
- calibration
- human-AI collaboration
- RAG
- hallucination
- source grounding
- legal analysis
- developer productivity
- software engineering
- financial stability
- model risk
- governance
- operational resilience
- third-party dependency
- training
- skill formation

Low-scoring papers often have only:

- benchmark
- leaderboard
- new architecture
- prompt examples
- case study without baseline
- vendor claims
- synthetic task
- proof-of-concept

But the system should not use keywords mechanically. It should use keywords to retrieve and then use evidence/task/actionability scoring to rank.

---

## 27. Source URLs referenced in this brief

### Mollick posts

- One Useful Thing home: https://www.oneusefulthing.org/
- “Secret Cyborgs: The Present Disruption in Three Papers”: https://www.oneusefulthing.org/p/secret-cyborgs-the-present-disruption
- “Centaurs and Cyborgs on the Jagged Frontier”: https://www.oneusefulthing.org/p/centaurs-and-cyborgs-on-the-jagged
- “Everyone is above average”: https://www.oneusefulthing.org/p/everyone-is-above-average
- “The Cybernetic Teammate”: https://www.oneusefulthing.org/p/the-cybernetic-teammate
- “Getting started with AI: Good enough prompting”: https://www.oneusefulthing.org/p/getting-started-with-ai-good-enough
- “Against Brain Damage”: https://www.oneusefulthing.org/p/against-brain-damage
- “Using AI Right Now: A Quick Guide”: https://www.oneusefulthing.org/p/using-ai-right-now-a-quick-guide

### Discovery tools and APIs

- Semantic Scholar Research Feeds FAQ: https://www.semanticscholar.org/faq/what-are-research-feeds
- Semantic Scholar create research feeds: https://www.semanticscholar.org/faq/create-research-feeds
- Semantic Scholar product/API: https://www.semanticscholar.org/product/api
- Semantic Scholar API docs: https://api.semanticscholar.org/api-docs/
- Semantic Scholar Recommendations API: https://api.semanticscholar.org/api-docs/recommendations
- SSRN Generative AI Special Topic Hub: https://www.ssrn.com/index.cfm/en/ai-gpt-3/
- NBER Working Papers: https://www.nber.org/papers
- NBER about: https://www.nber.org/about-nber
- arXiv API manual: https://info.arxiv.org/help/api/user-manual.html
- OpenAlex API overview: https://developers.openalex.org/api-reference/introduction
- Crossref REST API: https://www.crossref.org/documentation/retrieve-metadata/rest-api/

### Seed papers

- Peng et al., Copilot productivity: https://arxiv.org/abs/2302.06590
- Noy & Zhang, productivity effects: https://www.science.org/doi/10.1126/science.adh2586
- Noy & Zhang, SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4375283
- Felten, Raj & Seamans, arXiv: https://arxiv.org/abs/2303.01157
- Felten, Raj & Seamans, SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4375268
- Dell'Acqua et al., Jagged Frontier, SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4573321
- Dell'Acqua et al., Jagged Frontier, HBS: https://www.hbs.edu/faculty/Pages/item.aspx?num=64700
- Fabrizio Dell'Acqua author page: https://www.fabriziodellacqua.com/
- HBS AI Institute “Is AI Making Your Team Lazy?”: https://d3.harvard.edu/is-ai-making-your-team-lazy/
- Cybernetic Teammate, SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5188231
- Cybernetic Teammate, NBER: https://www.nber.org/papers/w33641
- Brynjolfsson, Li & Raymond, Generative AI at Work: https://www.nber.org/papers/w31161
- Choi & Schwarcz, AI Assistance in Legal Analysis: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4539836
- Schwarcz et al., AI-Powered Lawyering: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5162111
- Cui et al., High-Skilled Work, SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4945566
- Cui et al., Microsoft Research: https://www.microsoft.com/en-us/research/publication/the-effects-of-generative-ai-on-high-skilled-work-evidence-from-three-field-experiments-with-software-developers/
- Doshi & Hauser, Science Advances: https://www.science.org/doi/10.1126/sciadv.adn5290
- Doshi & Hauser, arXiv: https://arxiv.org/abs/2312.00506
- Goh et al., JAMA Network Open: https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825395
- From Chalkboards to Chatbots, World Bank: https://openknowledge.worldbank.org/entities/publication/15e1ff08-15ae-4f7a-b2a8-d146e6c113ee
- Your Brain on ChatGPT, arXiv: https://arxiv.org/abs/2506.08872

### Finance and regulatory sources

- BIS, “Intelligent financial system: how AI is transforming finance”: https://www.bis.org/publ/work1194.htm
- FSB, “The Financial Stability Implications of Artificial Intelligence”: https://www.fsb.org/2024/11/the-financial-stability-implications-of-artificial-intelligence/
- FSB, “Monitoring Adoption of Artificial Intelligence and Related Vulnerabilities in the Financial Sector”: https://www.fsb.org/2025/10/monitoring-adoption-of-artificial-intelligence-and-related-vulnerabilities-in-the-financial-sector/
- Bank of England / FCA, “Artificial intelligence in UK financial services - 2024”: https://www.bankofengland.co.uk/report/2024/artificial-intelligence-in-uk-financial-services-2024
- FCA AI/ML feedback statement: https://www.fca.org.uk/publications/feedback-statements/fs23-6-artifical-intelligence-machine-learning

---

## 28. Final design principle

The system should behave less like a search engine and more like a disciplined research analyst.

Its core loop should be:

```text
Discover → Filter → Score → Critique → Translate → Route → Learn
```

The highest-value output is not a pile of summaries. It is a small number of research-backed decisions:

- Pilot this workflow.
- Add this control.
- Train this population.
- Avoid this use case.
- Re-evaluate this assumption.
- Brief executives on this shift.
- Watch this regulatory risk.

That is the Mollick-style lesson: high-signal papers are the ones that change how people, organizations, and AI systems should work.
