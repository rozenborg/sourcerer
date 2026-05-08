# Ethan Mollick Public Research Reference Seed Corpus for Semantic Scholar Monitoring

**Version:** 0.1  
**Prepared for:** AI research-monitoring system design  
**Primary use case:** Build and tune Semantic Scholar feeds that surface high-signal AI research similar to the scholarly work Ethan Mollick tends to reference publicly.  
**Target operating environment:** Enterprise AI integration, especially regulated knowledge-work contexts such as JPMorganChase.  

---

## 1. Purpose of This Document

This document is a reference package for an AI system or engineering team that is building a research-monitoring workflow using Semantic Scholar, or a similar scholarly-search/recommendation API.

The goal is not merely to collect papers about artificial intelligence. The goal is to approximate the **selection function** visible in Ethan Mollick's public references: papers that are empirical, operationally useful, surprising, and relevant to how real people and organizations use AI.

This corpus should be used to seed recommendation feeds, author alerts, topic clusters, retrieval-augmented monitoring, executive digests, and downstream triage workflows.

---

## 2. Important Caveat

This is a broad practical seed corpus, not a guaranteed exhaustive bibliography of every scholarly article Ethan Mollick has ever referenced across every medium.

Ethan Mollick has referenced papers publicly through multiple channels, including but not limited to:

- One Useful Thing posts
- social media posts
- talks and interviews
- teaching materials
- book notes or citations
- comments and shared links
- podcasts and appearances

It is not realistic to certify that every one of those references is captured here. This document instead provides a **comprehensive working seed set** based on publicly visible references and closely related canonical articles that match his observed research-selection pattern.

Use this as **Seed Set v0.1**. The monitoring system should expand the list over time by discovering:

1. Papers directly cited in newly published Mollick posts.
2. Papers by authors whose work Mollick repeatedly cites.
3. Papers co-cited with the listed papers.
4. Papers recommended by Semantic Scholar from folders seeded with the highest-confidence entries.
5. Papers that match the observed Mollick-style filters described below.

---

## 3. What the System Should Learn from Mollick's Selection Pattern

Mollick's public research references tend to emphasize papers with one or more of these properties:

1. **Real work, not just benchmark performance**  
   Papers about professionals, employees, students, consultants, developers, lawyers, doctors, teachers, or teams using AI on recognizable tasks.

2. **Credible empirical comparisons**  
   Randomized controlled trials, field experiments, preregistered studies, quasi-experimental designs, controlled lab studies, real-world deployment data, or large-scale observational evidence.

3. **Human + AI performance, not just model-only performance**  
   Papers that compare humans, AI alone, and human-AI combinations.

4. **Evidence about boundaries and failure modes**  
   Papers that reveal where AI works, where it fails, where humans overrely on it, and where the “jagged frontier” matters.

5. **Operational implications**  
   Papers that can change workflow design, training, governance, controls, deployment strategy, or executive beliefs.

6. **Memorable managerial concepts**  
   Papers that can be turned into principles such as “jagged frontier,” “secret cyborgs,” “AI as skills leveler,” “cybernetic teammate,” “cognitive debt,” “AI reduces diversity,” or “good enough prompting.”

7. **Cross-domain analogical relevance**  
   Mollick often draws from medicine, education, law, creativity, software engineering, and economics because those domains reveal useful truths about AI adoption even outside the original setting.

For a regulated financial institution, the most valuable papers are those that can inform:

- where to deploy AI,
- where not to deploy AI,
- how to supervise AI,
- how to train employees,
- how to redesign workflows,
- how to govern AI,
- how to evaluate model performance in realistic work,
- how to manage overreliance, hallucination, and compliance risk.

---

## 4. Priority Codes

Use these codes as seed weights in the monitoring system.

| Code | Meaning | Recommended feed weight |
|---|---|---:|
| **A** | Directly discussed, linked, or clearly surfaced by Ethan Mollick in a main public post or highly visible public reference. | High |
| **B** | Publicly referenced, canonicalized from his discussion, closely related to directly referenced work, or a strong search variant. | Medium |
| **C** | Public social/comment reference, adjacent work, category seed, or weaker attribution. Verify before treating as a high-confidence Mollick citation. | Low |

Recommended usage:

- Save **A papers** as positive examples in Semantic Scholar folders.
- Use **B papers** as expansion seeds and co-citation anchors.
- Use **C papers** sparingly to avoid recommendation drift into generic AI content.
- Do not treat C papers as confirmed Mollick citations without verification.

---

## 5. Recommended Semantic Scholar Folder Taxonomy

Create separate Semantic Scholar folders rather than one broad “AI” folder. This improves recommendation quality and makes downstream routing easier.

Recommended folders:

1. **Mollick Seed — AI Work and Productivity**
2. **Mollick Seed — Human-AI Risk and Overreliance**
3. **Mollick Seed — Legal, Compliance, RAG, and Reasoning**
4. **Mollick Seed — Education and Skill Formation**
5. **Mollick Seed — Creativity and Innovation**
6. **Mollick Seed — Agents, Benchmarks, and Frontier Capability**
7. **Mollick Seed — AI Detection and Research Integrity**
8. **Mollick Seed — Finance and Regulated Enterprise AI**
9. **Mollick Seed — Prompting and Interaction Design**
10. **Mollick Seed — Scientific Research and Metascience**
11. **Mollick Seed — Persuasion, Social Interaction, and AI Companions**
12. **Mollick Seed — Scaling, Compute, and Governance**

Each folder should have both positive seeds and negative feedback. Mark irrelevant papers aggressively so the recommender learns the intended taste profile.

---

## 6. Comprehensive Seed Corpus

The following sections provide the corpus by theme. The same paper may be relevant to multiple folders; deduplicate by Semantic Scholar paper ID, DOI, arXiv ID, SSRN ID, or canonical title.

---

# 6.1 AI at Work, Productivity, Organizations, and Professional Performance

This is the central Mollick cluster: AI changing real work. It includes productivity, professional quality, team design, skill-leveling, organizational adoption, and field evidence.

Recommended folders:

- Mollick Seed — AI Work and Productivity
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Agents, Benchmarks, and Frontier Capability
- Mollick Seed — Finance and Regulated Enterprise AI, where applicable

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **The Impact of AI on Developer Productivity: Evidence from GitHub Copilot** | Core controlled productivity experiment; GitHub Copilot users completed coding work faster. | High-priority positive seed for developer productivity and SDLC tooling. |
| A | **Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence** | Noy & Zhang writing/productivity experiment with professionals; strong evidence for AI improving knowledge-work writing speed and quality. | High-priority seed for analyst, documentation, policy, and communication work. |
| A | **How Will Language Modelers Like ChatGPT Affect Occupations and Industries?** | Occupation and industry exposure mapping by Felten, Raj, and Seamans. | Use for workforce strategy and prioritization of exposed roles. |
| A | **Navigating the Jagged Technological Frontier: Field Experimental Evidence of the Effects of AI on Knowledge Worker Productivity and Quality** | BCG consultant experiment; central source for the “jagged frontier” idea. | Probably the single most important enterprise-AI seed paper in this corpus. |
| A | **Generative AI at Work** | Brynjolfsson, Li, and Raymond; real-world deployment evidence among customer-support agents, with larger gains for less-experienced workers. | Core “AI as skills leveler” seed. |
| A | **The Cybernetic Teammate: A Field Experiment on Generative AI Reshaping Teamwork and Expertise** | P&G field experiment on individuals, teams, functional expertise, and AI. | High-priority seed for team design and operating-model implications. |
| A | **The Effects of Generative AI on High-Skilled Work: Evidence from Three Field Experiments with Software Developers** | Developer field experiments across large organizations. | Route strong follow-ons to engineering, SDLC, and developer-experience teams. |
| A | **AI Assistance in Legal Analysis** | Legal reasoning and skill heterogeneity; useful for compliance-style reasoning. | Also seed in legal/compliance folder. |
| A | **AI-Powered Lawyering: AI Reasoning Models, Retrieval Augmented Generation, and the Future of Legal Practice** | RAG versus reasoning model versus no-AI legal-task experiment. | Highly relevant to regulated knowledge work and retrieval design. |
| A | **Evaluations at Work: Measuring the Capabilities of GenAI in Use** | Real-work evaluation framework; financial-professional valuation-style tasks. | High-priority seed for enterprise evaluation harnesses. |
| B | **Scaling Laws for Economic Productivity: Experimental Evidence in LLM-Assisted Translation** | Model scale and human productivity in translation; illustrates that frontier models can have materially different economic effects. | Use as productivity + scaling bridge seed. |
| B | **Selection with Variation in Diagnostic Skill: Evidence from Radiologists** | Non-AI but relevant for expert skill variance and selection in high-stakes domains. | Useful as analogical seed for expert-AI supervision. |
| B | **People and Process, Suits and Innovators: The Role of Individuals in Firm Performance** | Mollick's own management research; reflects his pre-AI lens on individuals, organizations, and firm performance. | Use sparingly as taste-modeling context, not AI monitoring. |
| B | **Promotions and the Peter Principle** | Management/organization-theory orbit; useful for human capital and promotion risk analogies. | Low-volume management context. |
| B | **Falling Asleep at the Wheel: Human/AI Collaboration in a Field Experiment** | Phrase associated with human overreliance and jagged frontier discussions. | Verify exact title/version before high-weighting. |
| C | **From Generative Pre-trained Transformer to General Purpose Technology** | Public comment/reference ecosystem; useful general-purpose technology framing. | Use as weak expansion seed. |

---

# 6.2 Creativity, Innovation, Ideation, and Entrepreneurship

This cluster captures Mollick's interest in AI as a creativity engine, idea generator, entrepreneurial assistant, and homogenization risk.

Recommended folders:

- Mollick Seed — Creativity and Innovation
- Mollick Seed — AI Work and Productivity
- Mollick Seed — Human-AI Risk and Overreliance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Using Large Language Models for Idea Generation in Innovation** | GPT-4 and product idea generation; Wharton-style innovation evidence. | High-priority creativity and product-ideation seed. |
| A | **The Crowdless Future? Generative AI and Creative Problem Solving** | AI versus crowdsourcing and creative problem solving. | Seed for innovation, crowdsourcing, and R&D workflows. |
| A | **Generative Artificial Intelligence Enhances Creativity but Reduces the Diversity of Novel Content** | Doshi and Hauser; AI raises individual creative quality but reduces diversity. | Important for enterprise homogenization risk. |
| A | **ChatGPT decreases idea diversity in brainstorming** | AI may reduce variance or diversity in brainstormed ideas. | Use as negative/control seed for creativity workflows. |
| A | **Prompting Diverse Ideas: Increasing AI Idea Variance** | Prompting strategies to increase idea diversity. | Useful for design of AI brainstorming systems. |
| A | **Creative and Strategic Capabilities of Generative AI: Evidence from Large-Scale Experiments** | Large-scale experiments on creative and strategic capability. | Good expansion seed for strategy and innovation work. |
| A | **An Empirical Investigation of the Impact of ChatGPT on Creativity** | Empirical creativity study. | Seed for creativity-effects literature. |
| A | **Artificial Muses: Generative Artificial Intelligence Chatbots Have Risen to Human-Level Creativity** | AI performance on divergent-thinking creativity tasks. | Use carefully; benchmark-style creativity results need operational validation. |
| A | **The Current State of Artificial Intelligence Generative Language Models Is More Creative Than Humans on Divergent Thinking Tasks** | AI divergent-thinking benchmark result. | Useful but should be paired with human-work studies. |
| A | **ChatGPT-4 Outperforms Experts and Crowd Workers in Creating New Product Ideas** | Search variant related to Wharton product-ideation work. | Use to find canonical version and variants. |
| B | **The Entrepreneurial Process: Evidence from a Nationally Representative Panel of Startups** | Entrepreneurship process evidence Mollick has discussed in broader entrepreneurship contexts. | Verify exact title/version before high-weighting. |
| B | **Founder Action Graph / Founder action-sequence papers by Victor Bennett and Aaron Chatterji** | Founder behavior and action sequencing. | Search by authors plus “founder action graph.” |
| B | **Learning to Become Entrepreneurs: A Randomized Experiment in Uganda** | Entrepreneurship education and democratization. | Useful for AI-enabled entrepreneurship education. |
| B | **Entrepreneurship education / mini-MBA randomized trial in Uganda** | Search variant for entrepreneurship training intervention. | Use for discovery if canonical title differs. |
| B | **Business training / social skills training for entrepreneurs in Tonga** | Entrepreneurship training and social skills intervention. | Search by “Tonga entrepreneurship social skills business training randomized trial.” |
| B | **Business skills training for entrepreneurs in Singapore** | Entrepreneurship training experiment. | Search by “Singapore entrepreneurship training randomized experiment business skills.” |

---

# 6.3 Education, Learning, Tutoring, Homework, and AI Pedagogy

Mollick has a dense education cluster. He often uses education research to reason about training, cognitive effort, AI tutors, learning harm, homework integrity, and how people acquire AI-related skills.

Recommended folders:

- Mollick Seed — Education and Skill Formation
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — AI Detection and Research Integrity

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Assigning AI: Seven Approaches for Students, with Prompts** | Mollick and Mollick practical education paper. | High-priority Mollick-authored education seed. |
| A | **Using AI to Implement Effective Teaching Strategies in Classrooms: Five Strategies, Including Prompts** | Mollick and Mollick; classroom teaching strategies with AI. | Useful for enterprise AI training design. |
| A | **Instructors as Innovators: A Future-Focused Approach to New AI Learning Opportunities, with Prompts** | Mollick and Mollick; instructors redesigning learning around AI. | Good seed for organizational learning and enablement. |
| A | **New Modes of Learning Enabled by AI Chatbots: Three Methods and Assignments** | Mollick and Mollick; AI-enabled learning modes. | Good training and simulation seed. |
| A | **AI Agents and Education: Simulated Practice at Scale** | AI roleplay/simulation learning. | Useful for enterprise simulation, manager training, and scenario practice. |
| A | **Generative AI Can Harm Learning** | Bastani et al.; AI can improve immediate performance while harming learning depending on design. | High-priority overreliance/cognitive-offloading seed. |
| A | **Generative AI Without Guardrails Can Harm Learning: Evidence from High School Mathematics** | Search variant for the Bastani et al. paper. | Canonicalize to the main version after retrieval. |
| A | **AI Meets the Classroom: When Do Large Language Models Harm Learning?** | Classroom/learning-harm study. | Pair with positive tutor studies. |
| A | **From Chalkboards to Chatbots: Evaluating the Impact of Generative AI on Learning Outcomes in Nigeria** | World Bank-style GPT tutor intervention. | High-priority training and tutoring seed. |
| A | **AI Tutoring Outperforms Active Learning** | AI tutor outperformance in a classroom setting. | Useful for training design; verify task/domain generalizability. |
| A | **The GPT Surprise: Offering Large Language Model Chat in a Massive Coding Class Reduced Engagement but Increased Exam Performance** | Large programming-class RCT; reduced engagement but improved exam performance. | Important nuanced outcome seed. |
| A | **ChatGPT-Assisted Retrieval Practice and Exam Scores: Does It Work?** | Retrieval practice and exam performance. | Use as learning-method design seed. |
| A | **Fewer Students Are Benefiting from Doing Their Homework: An Eleven-Year Study** | Homework integrity and internet/AI-era learning. | Use as context for assessment redesign. |
| A | **Backwards Planning with Generative AI: Case Study Evidence from US K12 Teachers** | Teacher planning workflow study. | Useful analog for staff workflow planning. |
| A | **Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task** | MIT Media Lab paper on cognitive debt; Mollick has discussed critically. | Use but evaluate methods carefully. |
| A | **The Unpleasantness of Thinking: A Meta-Analytic Review of the Association Between Mental Effort and Negative Affect** | Mental effort is often experienced negatively. | Important background for why users may overdelegate to AI. |
| A | **The Llama 3 Herd of Models** | Open model capability relevant to education and detection conversations. | Also seed in scaling/capability folders. |
| B | **The Effectiveness of ChatGPT in Assisting High School Students in Programming Learning: Evidence from a Quasi-Experimental Research** | Programming learning and ChatGPT support. | Related education seed. |
| B | **Is ChatGPT a Boon or a Bane for Learning? Experimental Evidence Across Task Formats and Chatbot Designs** | Chatbot design and task-format effects. | Good expansion seed. |
| B | **Leveling Up or Leveling Down? The Impact of Generative AI on Learning** | AI learning effect and heterogeneity. | Use as expansion seed. |
| B | **AI Learning Differences: Designing a Future with No Boundaries** | Learning differences and AI. | Use as low-to-medium education seed. |
| B | **Productive Struggle: The Future of Human Learning in the Age of AI** | Productive struggle and AI-era learning. | Useful concept seed. |

---

# 6.4 Medicine, Diagnosis, Expert Judgment, and Human-AI Overreliance

Mollick often uses medical research as an analog for expert work under uncertainty. These papers are especially useful for designing AI systems in regulated settings, because they reveal overreliance, calibration, decision support, and the limits of giving experts access to AI.

Recommended folders:

- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — AI Work and Productivity
- Mollick Seed — Agents, Benchmarks, and Frontier Capability

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Large Language Model Influence on Diagnostic Reasoning: A Randomized Clinical Trial** | Doctors with GPT-4 did not automatically outperform doctors without it; key human-AI collaboration paper. | High-priority overreliance and expert-use seed. |
| A | **Towards Accurate Differential Diagnosis with Large Language Models** | LLMs and differential diagnosis. | Use for model-only versus expert-assisted reasoning. |
| A | **Comparing Physician and Artificial Intelligence Chatbot Responses to Patient Questions Posted to a Public Social Media Forum** | Chatbot responses compared with physician responses. | Good for quality, empathy, and expert comparison. |
| A | **Can Generalist Foundation Models Outcompete Special-Purpose Tuning? Case Study in Medicine** | Generalist foundation model versus domain-tuned approach. | Useful analog for finance-domain versus general models. |
| A | **Towards Conversational Diagnostic AI** | AMIE / conversational diagnostic AI. | Useful for agentic diagnostic conversation systems. |
| A | **AMIE: A Research AI System for Diagnostic Medical Reasoning and Conversations** | Search variant for AMIE work. | Canonicalize after retrieval. |
| A | **Performance of ChatGPT and GPT-4 on Neurosurgery Written Board Examinations** | GPT-4 and medical board exam performance. | Benchmark-style but useful for capability tracking. |
| A | **Performance of ChatGPT, GPT-4, and Google Bard on a Neurosurgery Oral Boards Preparation Question Bank** | Related medical board benchmark. | Pair with real-world decision-support studies. |
| A | **GPT-4 Technical Report** | Foundational capability benchmark. | Also seed in frontier capability. |
| A | **Re-Evaluating GPT-4's Bar Exam Performance** | Benchmark skepticism; legal not medical, but included here because it parallels exam-performance overinterpretation. | Also seed in legal and benchmark skepticism folders. |
| B | **Can Large Language Models Diagnose Like a Physician?** | Search variant for diagnostic reasoning papers. | Use to discover related papers. |
| B | **Medical Large Language Models Are Not Yet Ready for Clinical Use** | Negative-control seed for clinical AI readiness. | Useful to balance overly optimistic medical AI results. |
| B | **Algorithmic Aversion and Appreciation in Human-AI Decision Making** | Foundational overreliance/aversion literature. | Use as conceptual background. |

---

# 6.5 Law, Legal Reasoning, Compliance-Style Tasks, and RAG

This category is highly relevant for banking and compliance because legal work shares many characteristics with bank controls: dense text, high stakes, exceptions, citations, auditability, and the risk of plausible but wrong answers.

Recommended folders:

- Mollick Seed — Legal, Compliance, RAG, and Reasoning
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Finance and Regulated Enterprise AI

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **AI Assistance in Legal Analysis** | Choi and Schwarcz; AI assistance in legal analysis and ability heterogeneity. | High-priority legal/compliance seed. |
| A | **AI-Powered Lawyering: AI Reasoning Models, Retrieval Augmented Generation, and the Future of Legal Practice** | RAG versus reasoning models versus no-AI for legal work. | High-priority RAG and legal-reasoning seed. |
| A | **Re-Evaluating GPT-4's Bar Exam Performance** | Important correction to simplistic bar-exam benchmark claims. | Use as benchmark skepticism seed. |
| B | **Large Language Models Pass the Bar Exam** | Earlier bar-exam capability claim. | Pair with re-evaluation paper. |
| B | **ChatGPT Goes to Law School** | Legal exam and law-school style evaluation. | Useful expansion seed. |
| B | **Large Language Models and Legal Reasoning** | Search/category seed. | Use for discovery, not as a canonical title unless resolved. |
| B | **Retrieval-Augmented Generation for Legal Question Answering** | Search/category seed for RAG legal QA. | Good for RAG monitoring. |
| B | **Hallucination-Free? Assessing Legal Citation Accuracy in Large Language Models** | Legal hallucination and citation risk. | Important risk/control expansion seed. |

---

# 6.6 Persuasion, Social Interaction, Emotional Support, AI Companions, and Chatbots

Mollick's public writing includes a cluster on AI persuasion, emotional support, AI companions, and human response to chatbots. These papers matter in enterprise settings because they reveal trust, persuasion, influence, loneliness, support, and safety dynamics in human-AI interaction.

Recommended folders:

- Mollick Seed — Persuasion, Social Interaction, and AI Companions
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Prompting and Interaction Design

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **On the Conversational Persuasiveness of Large Language Models: A Randomized Controlled Trial** | AI persuasion in conversation/debate. | High-priority social influence seed. |
| A | **Durably Reducing Conspiracy Beliefs Through Dialogues with AI** | AI dialogues reducing conspiracy beliefs. | Useful for persuasion and belief-updating research. |
| A | **Just the Facts: How Dialogues with AI Reduce Conspiracy Beliefs** | Follow-up on mechanism: rational argument versus manipulation. | Use with prior paper. |
| A | **Large Language Models Are Capable of Offering Cognitive Reappraisal, If Guided** | AI can provide cognitive reappraisal when guided. | Useful for coaching/support design. |
| A | **Exploring Human and AI Emotional Support Through Reframing of Negative Situations** | Search variant for emotional support/reappraisal work. | Canonicalize after retrieval. |
| A | **Chatbots and Mental Health: Insights into the Safety of Generative AI** | Mental-health chatbot safety. | High sensitivity; route to safety/governance. |
| A | **AI Companions Reduce Loneliness** | AI companion effects on loneliness. | Useful for human-AI attachment and support. |
| A | **Why Most Resist AI Companions** | Resistance to AI companions. | Useful for adoption and trust. |
| A | **The Leaderboard Illusion** | Chatbot or model leaderboard measurement issues. | Use as evaluation skepticism seed. |
| B | **The Typing Cure: Experiences with Large Language Model Chatbots for Mental Health Support** | Mental-health support via LLM chatbots. | Expansion seed. |
| B | **Trusting Emotional Support from Generative Artificial Intelligence** | Trust in AI emotional support. | Expansion seed. |
| B | **AI-Generated Empathy: Opportunities, Limits, and Risks** | Search/category seed for empathy research. | Use for discovery. |
| C | **Reddit debate-bot persuasion field study** | Mollick has mentioned a Reddit bot study in public discussion; exact formal title should be verified. | Low confidence until canonical title is found. |

---

# 6.7 Prompting, Prompt Sensitivity, Reasoning, and Interaction Design

Mollick has emphasized that prompting is model-specific, contingent, and often overcomplicated. He highlights evidence that small prompt differences can matter, while also cautioning against magical thinking about prompts.

Recommended folders:

- Mollick Seed — Prompting and Interaction Design
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Agents, Benchmarks, and Frontier Capability

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Chain-of-Thought Prompting Elicits Reasoning in Large Language Models** | Foundational CoT paper. | High-priority technical prompting seed. |
| A | **Quantifying Language Models' Sensitivity to Spurious Features in Prompt Design or: How I Learned to Start Worrying About Prompt Formatting** | Prompt formatting sensitivity. | Useful for prompt reliability. |
| A | **Re-Reading Improves Reasoning in Language Models** | Re-reading as a reasoning-improvement prompting method. | Useful for prompt technique monitoring. |
| A | **Should We Respect LLMs? A Cross-Lingual Study on the Influence of Prompt Politeness on LLM Performance** | Politeness effects across languages. | Interesting but should not drive enterprise prompt standards alone. |
| A | **ProSA: Assessing and Understanding the Prompt Sensitivity of LLMs** | Prompt sensitivity benchmark. | Good evaluation seed. |
| A | **Large Language Models Understand and Can Be Enhanced by Emotional Stimuli** | Emotional stimuli in prompts. | Use with skepticism; monitor replications/critiques. |
| A | **Prompt Engineering Is Complicated and Contingent** | Prompting Science Report; Mollick/Mollick/Shapiro/Meincke. | High-priority Mollick-authored prompt-practice seed. |
| A | **The Decreasing Value of Chain of Thought in Prompting** | Prompting Science Report. | Important as models evolve. |
| A | **I'll Pay You or I'll Kill You — But Will You Care?** | Prompting Science Report on incentives/threats/emotional prompts. | Use as empirical prompt folklore test. |
| A | **Playing Pretend: Expert Personas Don't Improve Factual Accuracy** | Prompting Science Report on persona prompting. | Useful for debunking prompt myths. |
| A | **This Is an Excellent Paper: The Effects of Prompt Injection** | Prompting Science Report; prompt injection effects. | Also route to AI safety/security. |
| B | **Provocations Help Restore Critical Thinking to AI-Assisted Knowledge Work** | Intervention to restore critical thinking during AI-assisted work. | Strong fit with Mollick's overreliance theme. |
| B | **Co-Writing with Opinionated Language Models Affects Users' Views** | AI co-writing may shape users' views. | Useful for persuasion and writing-assistant governance. |
| B | **Do Users Write More Critically with AI Feedback?** | Search/category seed. | Use for discovery. |

---

# 6.8 Agents, Benchmarks, Task Horizons, and Frontier-Model Evaluation

Mollick's recent agentic-work discussions emphasize long-horizon work, real-world economically valuable tasks, task-horizon measurement, and the shift from “using AI” to “managing AI.”

Recommended folders:

- Mollick Seed — Agents, Benchmarks, and Frontier Capability
- Mollick Seed — AI Work and Productivity
- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Finance and Regulated Enterprise AI

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Measuring AI Ability to Complete Long Tasks** | METR-style task horizon measurement. | High-priority agent capability seed. |
| A | **The Illusion of Diminishing Returns: Measuring Long Horizon Execution in LLMs** | Long-horizon execution benchmark. | Use for agentic monitoring. |
| A | **GDPval: Evaluating AI Model Performance on Real-World Economically Valuable Tasks** | OpenAI GDPval; economically valuable real-world tasks. | High-priority real-work benchmark seed. |
| A | **Evaluations at Work: Measuring the Capabilities of GenAI in Use** | Real-world work evaluation framework. | High-priority enterprise-eval seed. |
| A | **Sparks of Artificial General Intelligence: Early Experiments with GPT-4** | Microsoft GPT-4 capability paper. | Core frontier capability seed. |
| A | **GPT-4 Technical Report** | Foundational technical report. | Core capability baseline. |
| A | **Algorithmic Progress in Language Models** | Progress in language model capabilities. | Use for trend monitoring. |
| A | **The Llama 3 Herd of Models** | Meta Llama 3/3.1 technical report. | Important open-model capability seed. |
| A | **Thousands of AI Authors on the Future of AI** | Expert survey on future AI timelines and impacts. | Use for forecasting context, not direct deployment. |
| B | **Humanity's Last Exam** | Recent benchmark/capability reference. | Benchmark seed; verify current status. |
| B | **GPQA: A Graduate-Level Google-Proof Q&A Benchmark** | Difficult expert QA benchmark. | Useful for reasoning capability tracking. |
| B | **SWE-bench: Can Language Models Resolve Real-World GitHub Issues?** | Real-world software issue benchmark. | Crucial for software-agent monitoring. |
| B | **SWE-bench Verified** | Verified subset of SWE-bench. | Use for agentic software reliability. |
| B | **OpenAI o1 System Card / o1 Technical Report** | Reasoning model reference. | Use official/technical docs; not always Semantic Scholar article. |
| B | **Claude / Anthropic agentic coding benchmark papers** | Agentic coding and tool-use benchmarks. | Use for discovery. |
| C | **AI 2027** | Scenario document, not a scholarly article. | Do not treat as research seed except for scenario-planning context. |

---

# 6.9 Scaling, Compute, Model Capability, Domain Models, and Governance

Mollick has referenced papers and reports related to scaling, compute, finance-domain models, and governance. These papers help the monitoring system understand the capability frontier and whether domain-specific models are being overtaken by general frontier models.

Recommended folders:

- Mollick Seed — Scaling, Compute, and Governance
- Mollick Seed — Agents, Benchmarks, and Frontier Capability
- Mollick Seed — Finance and Regulated Enterprise AI

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Computing Power and the Governance of Artificial Intelligence** | Compute governance and AI capability. | Governance/scaling seed. |
| A | **BloombergGPT: A Large Language Model for Finance** | Finance-domain LLM. | High-priority finance AI seed. |
| A | **Are ChatGPT and GPT-4 General-Purpose Solvers for Financial Text Analytics?** | General-purpose GPT models versus financial NLP models. | Very relevant to bank AI strategy. |
| A | **Scaling Laws for Economic Productivity: Experimental Evidence in LLM-Assisted Translation** | Links model scaling with productivity. | Bridge between scaling and economic value. |
| A | **Algorithmic Progress in Language Models** | Tracks progress in language model performance. | Core frontier-monitoring seed. |
| A | **The Llama 3 Herd of Models** | Open model capability report. | Open model monitoring. |
| A | **GPT-4 Technical Report** | Foundational model capability report. | Baseline seed. |
| B | **Will We Run Out of Data? Limits of LLM Scaling Based on Human-Generated Data** | Data limits for scaling. | Scaling constraint seed. |
| B | **Training Compute-Optimal Large Language Models** | Chinchilla scaling law. | Background seed; not Mollick-specific. |
| B | **Scaling Laws for Neural Language Models** | Kaplan et al. scaling laws. | Background seed. |
| C | **The Curse of Recursion: Training on Generated Data Makes Models Forget** | Synthetic-data/model-collapse issue; public comment ecosystem reference. | Use as weak but important risk seed. |

---

# 6.10 AI Detection, AI Writing, Academic Integrity, and Watermarking

Mollick has written skeptically about detection-based approaches to AI writing. This category captures detection failures, detector bias, AI-generated text detection, and human inability to distinguish AI writing from human writing.

Recommended folders:

- Mollick Seed — AI Detection and Research Integrity
- Mollick Seed — Education and Skill Formation
- Mollick Seed — Human-AI Risk and Overreliance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **GPT Detectors Are Biased Against Non-Native English Writers** | Detector bias against non-native English writers. | High-priority fairness and detection-risk seed. |
| A | **Can AI-Generated Text Be Reliably Detected?** | Detection reliability. | High-priority detection skepticism seed. |
| A | **A Survey on LLM-Generated Text Detection: Necessity, Methods, and Future Directions** | Survey of detection methods and limitations. | Useful for detection landscape. |
| A | **Do Teachers Spot AI? Evaluating the Detectability of AI-Generated Texts Among Student Essays** | Teachers' ability to detect AI-generated essays. | Relevant to human detection limits. |
| A | **GPT-4 Is Judged More Human Than Humans in Displaced and Inverted Turing Tests** | Well-prompted AI judged more human than humans. | Useful for human-detection failure. |
| A | **Can Linguists Distinguish Between ChatGPT/AI and Human Writing?** | Linguistics reviewers/editors struggled to distinguish AI from human abstracts. | High-priority academic-integrity seed. |
| B | **Comparing Scientific Abstracts Generated by ChatGPT to Real Abstracts with Detectors and Human Reviewers** | Abstract detection and human review. | Expansion seed. |
| B | **Human Detection of AI-Generated Text: A Survey** | Search/category seed. | Use for discovery. |
| B | **Detecting AI-Generated Text in the Wild** | Search/category seed. | Use for discovery. |
| B | **Initial Indications of Generative AI Writing in Linguistics Research Publications** | Evidence of AI-style writing markers in publications. | Useful for research-integrity monitoring. |
| C | **Watermarking Large Language Model Outputs** | Technical watermarking concept. | Adjacent technical seed. |
| C | **A Watermark for Large Language Models** | Search variant. | Use for watermarking discovery. |

---

# 6.11 Scientific Writing, Peer Review, Metascience, and AI-Accelerated Research

Mollick has discussed AI's potential to transform research itself: writing, peer review, feedback, automated discovery, scientific verification, and autonomous research systems.

Recommended folders:

- Mollick Seed — Scientific Research and Metascience
- Mollick Seed — AI Detection and Research Integrity
- Mollick Seed — Agents, Benchmarks, and Frontier Capability

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **ChatGPT-4 and Human Researchers Are Equal in Writing Scientific Introduction Sections: A Blinded, Randomized, Non-Inferiority Controlled Study** | AI scientific writing study. | High-priority metascience seed. |
| A | **Monitoring AI-Modified Content at Scale: A Case Study on the Impact of ChatGPT on AI Conference Peer Reviews** | AI-modified peer reviews. | Research integrity seed. |
| A | **The AI Review Lottery: Widespread AI-Assisted Peer Reviews Boost Paper Scores and Acceptance Rates** | AI-assisted peer reviews and acceptance effects. | High-priority peer-review governance seed. |
| A | **Can Large Language Models Provide Useful Feedback on Research Papers? A Large-Scale Empirical Analysis** | LLM feedback on research papers. | Useful for internal research-review tools. |
| A | **Evaluating Science: A Comparison of Human and AI Reviewers** | AI reviewers versus human reviewers. | Search/canonicalize exact title if needed. |
| A | **Mathematical Discoveries from Program Search with Large Language Models** | FunSearch / mathematical discovery. | Important AI-for-science seed. |
| A | **Automated Social Science: Language Models as Scientist and Subjects** | AI as scientist and simulated subject. | Useful for automated research workflows. |
| A | **Autonomous Chemical Research with Large Language Models** | Autonomous chemical research. | Agentic scientific discovery seed. |
| B | **When AI Co-Scientists Fail: SPOT — A Benchmark for Automated Verification of Scientific Research** | Error verification benchmark. | Use as corrective/negative seed. |
| B | **AI Tools Are Spotting Errors in Research Papers: Inside a Growing Movement** | News feature, not scholarly paper, but useful for tracing related projects. | Use only as discovery pointer. |
| B | **From e-Waste to Living Space: Flame Retardants Contaminating Household Items Add to Concern About Plastic Recycling** | Black-plastic paper used in discussion of AI spotting a math error. | Use as example context, not core AI seed. |
| B | **Can Large Language Models Verify Scientific Claims?** | Search/category seed. | Use for discovery. |
| B | **LLMs as Research Assistants: A Survey** | Search/category seed. | Use for broad map. |
| C | **AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery** | Adjacent AI scientist work. | Use as low-confidence Mollick-adjacent seed. |

---

# 6.12 AI-Human Collaboration, Overreliance, Critical Thinking, and Cognitive Offloading

This section overlaps with several others but should be treated as a distinct monitoring lane because overreliance and critical thinking are central enterprise AI risks.

Recommended folders:

- Mollick Seed — Human-AI Risk and Overreliance
- Mollick Seed — Education and Skill Formation
- Mollick Seed — AI Work and Productivity
- Mollick Seed — Legal, Compliance, RAG, and Reasoning

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Navigating the Jagged Technological Frontier** | Central overreliance/frontier paper. | Core seed. |
| A | **Large Language Model Influence on Diagnostic Reasoning: A Randomized Clinical Trial** | Experts with AI do not automatically improve. | Core expert-overreliance seed. |
| A | **Generative AI Can Harm Learning** | Learning harm and overreliance. | Core cognitive-offloading seed. |
| A | **Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task** | Cognitive debt. | Use with methodological scrutiny. |
| A | **The Unpleasantness of Thinking** | Humans often dislike cognitive effort. | Useful behavioral foundation. |
| B | **Provocations Help Restore Critical Thinking to AI-Assisted Knowledge Work** | Intervention design for critical thinking. | Strong enterprise relevance. |
| B | **The Impact of Generative AI on Critical Thinking** | Search/category seed. | Use for discovery. |
| B | **Human-AI Collaboration: A Survey** | Broad survey seed. | Use for related-work expansion. |
| B | **Automation Bias in Decision Support Systems** | Foundational non-LLM literature. | Use as conceptual background. |
| B | **Algorithmic Aversion: People Erroneously Avoid Algorithms After Seeing Them Err** | Foundational algorithm aversion. | Use for human-AI trust literature. |
| B | **Algorithm Appreciation: People Prefer Algorithmic to Human Judgment** | Complement to algorithmic aversion. | Use for trust calibration. |
| B | **Cognitive Offloading: How the Internet Is Increasingly Taking Over Human Memory** | Foundational cognitive offloading. | Use as background. |

---

# 6.13 AI, Employment, Labor Markets, Exposure, and Economic Impact

Mollick's public references often connect AI to labor exposure, productivity, skill-leveling, and the future of work. This section should be used for macro and workforce strategy.

Recommended folders:

- Mollick Seed — AI Work and Productivity
- Mollick Seed — Finance and Regulated Enterprise AI
- Mollick Seed — Scaling, Compute, and Governance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **How Will Language Modelers Like ChatGPT Affect Occupations and Industries?** | Occupation and industry exposure. | Core workforce strategy seed. |
| A | **Generative AI at Work** | Real deployment and skill-leveling. | Core productivity seed. |
| A | **Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence** | Writing-productivity RCT. | Core knowledge-work seed. |
| A | **Navigating the Jagged Technological Frontier** | Consulting work and frontier boundaries. | Core professional-work seed. |
| A | **The Effects of Generative AI on High-Skilled Work** | Developer productivity. | Engineering workforce seed. |
| A | **Scaling Laws for Economic Productivity** | Translator productivity and model scale. | Scaling/productivity seed. |
| B | **GPTs Are GPTs: An Early Look at the Labor Market Impact Potential of Large Language Models** | Occupational exposure paper. | Likely useful regardless of exact Mollick citation status. |
| B | **Artificial Intelligence and the Future of Work** | NBER-style search/category seed. | Use for discovery. |
| B | **AI and Jobs: Evidence from Online Vacancies** | Labor-market signal from vacancies. | Use for workforce monitoring. |
| B | **The Simple Macroeconomics of AI** | Economic impact seed. | Use for macro context. |
| B | **The Turing Transformation: Artificial Intelligence, Intelligence Augmentation, and Skill Premiums** | AI and skill premiums. | Use for labor economics. |

---

# 6.14 AI in Finance, Financial Tasks, Banking Relevance, and Domain-Specific Models

Mollick is not primarily a finance researcher, but some of the papers he references or that fit his filter are directly relevant to banks. This should be a dedicated folder because JPMC needs a sector-specific overlay on the broader Mollick-style feed.

Recommended folders:

- Mollick Seed — Finance and Regulated Enterprise AI
- Mollick Seed — Legal, Compliance, RAG, and Reasoning
- Mollick Seed — Agents, Benchmarks, and Frontier Capability
- Mollick Seed — Scaling, Compute, and Governance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **BloombergGPT: A Large Language Model for Finance** | Finance-domain LLM. | Core finance-domain seed. |
| A | **Are ChatGPT and GPT-4 General-Purpose Solvers for Financial Text Analytics?** | General-purpose versus finance-specific LLM performance. | Core banking strategy seed. |
| A | **Evaluations at Work: Measuring the Capabilities of GenAI in Use** | Real-work evaluation, including financial-professional-style tasks. | Core enterprise evaluation seed. |
| A | **GDPval: Evaluating AI Model Performance on Real-World Economically Valuable Tasks** | Economically valuable task benchmark. | Important for enterprise task evaluation. |
| B | **FinGPT: Open-Source Financial Large Language Models** | Open-source financial LLMs. | Expansion seed. |
| B | **PIXIU: A Large Language Model, Instruction Data and Evaluation Benchmark for Finance** | Finance LLM and benchmark. | Expansion seed. |
| B | **FinBench / FinanceBench: A New Benchmark for Financial Question Answering** | Financial QA benchmark. | Important RAG/evaluation seed. |
| B | **Can Large Language Models Beat Wall Street?** | Search variant; verify title/version. | Use for discovery. |
| B | **Large Language Models in Finance: A Survey** | Broad survey seed. | Use to map finance LLM literature. |
| B | **Generative AI in Financial Services** | Search/category seed. | Pair with BIS, FSB, Fed, OCC, SEC, FINRA, and FCA/Bank of England publications. |

---

# 6.15 Model Collapse, Synthetic Data, and AI-Generated-Content Feedback Loops

This category appears more in public comment/reference ecosystems than in core Mollick main-post references, but it is important for monitoring the long-term reliability of AI systems and research corpora.

Recommended folders:

- Mollick Seed — Scaling, Compute, and Governance
- Mollick Seed — AI Detection and Research Integrity
- Mollick Seed — Human-AI Risk and Overreliance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| C | **The Curse of Recursion: Training on Generated Data Makes Models Forget** | Model-collapse / synthetic-data feedback issue. | Low-confidence Mollick attribution but important risk seed. |
| C | **Model Collapse: Degenerative Dynamics in Generative Models Trained on Generated Data** | Model collapse. | Category seed. |
| C | **AI Models Collapse When Trained on Recursively Generated Data** | Search variant. | Category seed. |
| C | **Self-Consuming Generative Models Go MAD** | Synthetic-data feedback loop. | Category seed. |
| C | **The Curse of Synthetic Data: Model Collapse** | Search variant. | Category seed. |

---

# 6.16 Miscellaneous Benchmark and Capability Papers

These papers are useful for tracking frontier capability and evaluation, though they should not dominate the feed unless they connect to real work, governance, agents, or evaluation quality.

Recommended folders:

- Mollick Seed — Agents, Benchmarks, and Frontier Capability
- Mollick Seed — Scaling, Compute, and Governance

| Priority | Title | Context / why it matters | Handling notes |
|---|---|---|---|
| A | **Sparks of Artificial General Intelligence: Early Experiments with GPT-4** | Early GPT-4 capability exploration. | Core frontier seed. |
| A | **GPT-4 Technical Report** | Foundational GPT-4 report. | Core frontier seed. |
| A | **The Llama 3 Herd of Models** | Open model capability report. | Core open-model seed. |
| A | **Algorithmic Progress in Language Models** | Tracks progress over time. | Use for capability trend monitoring. |
| A | **Thousands of AI Authors on the Future of AI** | Expert survey on future AI. | Forecasting context. |
| B | **GPQA: A Graduate-Level Google-Proof Q&A Benchmark** | Advanced reasoning benchmark. | Good frontier benchmark seed. |
| B | **Humanity's Last Exam** | Difficult benchmark. | Verify current version and provenance. |
| B | **Measuring Massive Multitask Language Understanding** | MMLU. | Baseline benchmark seed. |
| B | **Beyond the Imitation Game: Quantifying and Extrapolating the Capabilities of Language Models** | BIG-bench. | Benchmark background. |
| B | **Holistic Evaluation of Language Models** | HELM. | Evaluation framework seed. |
| B | **Chatbot Arena: An Open Platform for Evaluating LLMs by Human Preference** | Human-preference model comparison. | Useful but not a substitute for task-specific enterprise evaluation. |
| B | **The Leaderboard Illusion** | Leaderboard critique. | Evaluation skepticism seed. |
| B | **The Hallucination Leaderboard / Hallucination benchmark papers** | Reliability and hallucination benchmarks. | Use as category seed. |

---

## 7. Highest-Value Initial Seed Set

If the system can only begin with a smaller high-quality set, use the following 40 titles first. These best approximate the Mollick selection function: real work, human-AI comparison, empirical design, frontier capability, learning, overreliance, and enterprise relevance.

```text
The Impact of AI on Developer Productivity: Evidence from GitHub Copilot
Experimental Evidence on the Productivity Effects of Generative Artificial Intelligence
How Will Language Modelers Like ChatGPT Affect Occupations and Industries?
Navigating the Jagged Technological Frontier: Field Experimental Evidence of the Effects of AI on Knowledge Worker Productivity and Quality
Generative AI at Work
The Cybernetic Teammate: A Field Experiment on Generative AI Reshaping Teamwork and Expertise
The Effects of Generative AI on High-Skilled Work: Evidence from Three Field Experiments with Software Developers
AI Assistance in Legal Analysis
AI-Powered Lawyering: AI Reasoning Models, Retrieval Augmented Generation, and the Future of Legal Practice
Evaluations at Work: Measuring the Capabilities of GenAI in Use
GDPval: Evaluating AI Model Performance on Real-World Economically Valuable Tasks
Scaling Laws for Economic Productivity: Experimental Evidence in LLM-Assisted Translation
Using Large Language Models for Idea Generation in Innovation
The Crowdless Future? Generative AI and Creative Problem Solving
Generative Artificial Intelligence Enhances Creativity but Reduces the Diversity of Novel Content
Prompting Diverse Ideas: Increasing AI Idea Variance
Generative AI Can Harm Learning
AI Meets the Classroom: When Do Large Language Models Harm Learning?
From Chalkboards to Chatbots: Evaluating the Impact of Generative AI on Learning Outcomes in Nigeria
AI Tutoring Outperforms Active Learning
The GPT Surprise: Offering Large Language Model Chat in a Massive Coding Class Reduced Engagement but Increased Exam Performance
Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task
Large Language Model Influence on Diagnostic Reasoning: A Randomized Clinical Trial
Towards Accurate Differential Diagnosis with Large Language Models
Comparing Physician and Artificial Intelligence Chatbot Responses to Patient Questions Posted to a Public Social Media Forum
Towards Conversational Diagnostic AI
On the Conversational Persuasiveness of Large Language Models: A Randomized Controlled Trial
Durably Reducing Conspiracy Beliefs Through Dialogues with AI
Large Language Models Are Capable of Offering Cognitive Reappraisal, If Guided
Chatbots and Mental Health: Insights into the Safety of Generative AI
AI Companions Reduce Loneliness
Chain-of-Thought Prompting Elicits Reasoning in Large Language Models
Quantifying Language Models' Sensitivity to Spurious Features in Prompt Design
Re-Reading Improves Reasoning in Language Models
Should We Respect LLMs? A Cross-Lingual Study on the Influence of Prompt Politeness on LLM Performance
Sparks of Artificial General Intelligence: Early Experiments with GPT-4
GPT-4 Technical Report
Algorithmic Progress in Language Models
Measuring AI Ability to Complete Long Tasks
The Illusion of Diminishing Returns: Measuring Long Horizon Execution in LLMs
```

---

## 8. Author Watchlist

Semantic Scholar should monitor these authors and coauthors, especially when new papers involve generative AI, LLMs, knowledge work, productivity, organizations, law, medicine, education, or human-AI collaboration.

### 8.1 AI, Work, Productivity, and Organizations

| Researcher | Why monitor |
|---|---|
| Ethan Mollick | Public selector and author; AI at work, education, entrepreneurship. |
| Lilach Mollick | AI education, prompting, learning design. |
| Fabrizio Dell'Acqua | BCG jagged frontier, P&G cybernetic teammate, human-AI professional work. |
| Karim Lakhani | Harvard/LISH, field experiments, innovation science, AI and organizations. |
| Hila Lifshitz-Assaf | Innovation, knowledge work, organizational transformation. |
| Katherine Kellogg | AI in organizations, algorithmic management, implementation. |
| Raffaella Sadun | Management, productivity, organizational economics. |
| Edward McFowland III | AI, organizations, field experiments. |
| Charles Ayoubi | AI and product development / innovation. |
| Lindsey Raymond | Generative AI at work; customer-support productivity evidence. |
| Danielle Li | AI productivity and worker effects. |
| Erik Brynjolfsson | AI productivity, digital economy, labor effects. |

### 8.2 Economics, Labor, and Exposure

| Researcher | Why monitor |
|---|---|
| Edward Felten | AI exposure mapping. |
| Manav Raj | AI and occupations/industries. |
| Robert Seamans | AI economics and labor-market exposure. |
| David Autor | Labor-market effects of technology. |
| Daron Acemoglu | Automation, productivity, labor displacement. |
| Mert Demirer | AI and firm productivity. |
| Zheyuan Cui | Software-developer field experiments. |
| Sida Peng | Copilot developer productivity. |
| Sonia Jaffe | Developer productivity and AI. |
| Tobias Salz | Developer productivity and AI. |
| Leon Musolff | Developer productivity and AI. |

### 8.3 Legal, Compliance, and Reasoning-Heavy Work

| Researcher | Why monitor |
|---|---|
| Daniel Schwarcz | AI and lawyering, legal education, legal analytics. |
| Jonathan Choi | Empirical legal-AI studies. |
| J.J. Prescott | Legal systems and empirical law. |
| Sam Manning | Legal AI and RAG/reasoning experiments. |
| Beverly Rich | AI and legal education/profession. |

### 8.4 Medicine, Human-AI Judgment, and Overreliance

| Researcher | Why monitor |
|---|---|
| Ethan Goh | GPT-4 diagnostic reasoning RCT. |
| Jonathan Chen | Clinical AI and human-AI decision-making. |
| Adam Rodman | Medical reasoning and AI diagnosis. |
| Eric Horvitz | Human-AI interaction, decision support, reliability. |
| Anil Doshi | AI creativity and diversity effects. |
| Oliver Hauser | Creativity, judgment, human-AI behavior. |
| Christian Terwiesch | AI ideation and product innovation. |
| Lennart Meincke | AI product ideation and innovation. |
| Karl Ulrich | Product innovation and AI creativity. |

---

## 9. Source and Venue Watchlist

The system should not rely only on journals. Many high-signal Mollick-style papers appear first as working papers or preprints.

### 9.1 Primary Places to Monitor

| Source | Why monitor |
|---|---|
| Semantic Scholar Research Feeds | Adaptive recommendations based on saved papers and relevance feedback. |
| SSRN | Many AI-at-work, law, business, and economics working papers appear here early. |
| NBER Working Papers | Productivity, labor, organizational economics, firm-level AI adoption. |
| arXiv | Technical AI, benchmarks, agents, LLM evaluation, safety, RAG. |
| ACL Anthology | NLP, evaluation, prompting, retrieval, language-model behavior. |
| ACM Digital Library | CHI, CSCW, FAccT, HCI, sociotechnical systems. |
| Harvard Business School / AI Institute / D^3 | Management, organizations, AI adoption, field experiments. |
| Harvard LISH | Innovation science and field experiments. |
| Wharton faculty pages / Wharton AI | AI in entrepreneurship, creativity, education, and business. |
| MIT Sloan / MIT IDE | Digital economy, productivity, labor, organizations. |
| Stanford HAI / Digital Economy Lab | Human-AI systems, policy, labor, AI in work. |
| Microsoft Research / GitHub Research | Developer productivity, Copilot, software agents. |
| Google DeepMind / Google Research | Medicine, agents, frontier models, AI science. |
| OpenAI research / system cards / eval reports | Frontier capability and evaluation. |
| Anthropic research | Safety, agents, capability evaluation. |
| Meta AI research | Open models and capability reports. |

### 9.2 Finance and Regulatory Sources

For JPMorganChase-specific monitoring, add a separate regulated-finance stream.

| Source | Why monitor |
|---|---|
| BIS | AI in financial intermediation, payments, stability, prudential policy. |
| FSB | Global AI vulnerabilities, third-party dependency, cyber risk, model risk. |
| Federal Reserve working papers / FEDS Notes | AI adoption, financial markets, macro effects. |
| OCC | Bank supervision, model governance, operational risk. |
| SEC | Market integrity, disclosure, AI washing, investment adviser use. |
| FINRA | Broker-dealer AI use, supervision, communications. |
| Bank of England / FCA | AI/ML in financial services and macroprudential implications. |
| IOSCO | Securities-market AI governance. |

---

## 10. Journal and Conference Watchlist

| Area | Journals / venues to monitor |
|---|---|
| Economics and productivity | Quarterly Journal of Economics, American Economic Review, AEJ: Applied Economics, NBER Working Papers. |
| Management and organizations | Management Science, Organization Science, Administrative Science Quarterly, Strategic Management Journal, Information Systems Research, MIS Quarterly. |
| Human-AI interaction | ACM CHI, CSCW, Proceedings of the ACM on Human-Computer Interaction. |
| Responsible AI and governance | ACM FAccT, AIES, AI & Society, Big Data & Society. |
| NLP and LLMs | ACL, EMNLP, NAACL, ACL Anthology. |
| Technical AI evaluation | NeurIPS, ICML, ICLR, arXiv. |
| Law and AI | Journal of Legal Education, Journal of Law and Empirical Analysis, Yale Journal of Law & Technology, SSRN legal eJournals. |
| Medicine / decision support | JAMA Network Open, JAMA Internal Medicine, The Lancet Digital Health, Nature Medicine. |
| Finance and regulation | BIS Working Papers, FSB reports, Federal Reserve FEDS Notes, Bank of England/FCA publications, SEC/FINRA/OCC publications. |

---

## 11. Relevance Scoring Rubric

When the system discovers a new paper, score it before summarizing deeply.

Maximum score before penalties: 10.

| Dimension | Score |
|---|---:|
| Direct relevance to AI integration in enterprise knowledge work | 0–2 |
| Realistic task or workplace setting | 0–2 |
| Credible evidence design | 0–2 |
| Measures quality, risk, or error, not just speed | 0–2 |
| Changes a decision, control, pilot, workflow, or training plan | 0–2 |
| Hype penalty: vague, benchmark-only, no baseline, tiny sample, vendor marketing, or overclaimed result | subtract 0–3 |

Recommended action by score:

| Score | Action |
|---:|---|
| 9–10 | Executive brief candidate; consider pilot/control implication. |
| 7–8 | Read and create decision card. |
| 5–6 | Monitor; summarize only if connected to strategic lane. |
| 3–4 | Save only if useful as background. |
| 0–2 | Ignore or mark irrelevant. |

---

## 12. Decision Card Schema

For each paper scoring 7 or higher, create a decision card.

```yaml
paper_id: ""
title: ""
authors: []
year: null
venue_or_source: ""
url: ""
doi: ""
arxiv_id: ""
ssrn_id: ""
semantic_scholar_id: ""
priority_code: "A|B|C|new"
source_category: "work_productivity|legal_rag|education|creativity|medicine|agents|finance|prompting|detection|metascience|other"
claim_one_sentence: ""
evidence_type: "RCT|field_experiment|lab_experiment|observational|benchmark|survey|technical_report|review|case_study|other"
task_domain: ""
population: "professionals|students|experts|crowd_workers|employees|model_only|mixed|other"
human_baseline: true
ai_baseline: true
human_ai_condition: true
models_or_tools_tested: []
main_effects:
  speed: ""
  quality: ""
  accuracy: ""
  cost: ""
  satisfaction: ""
  risk_or_error: ""
limitations: []
failure_modes: []
overreliance_risks: []
security_privacy_compliance_implications: []
model_risk_implications: []
auditability_implications: []
jpmc_relevance: "high|medium|low"
recommended_action: "pilot|monitor|brief_executives|send_to_risk|send_to_legal|send_to_engineering|ignore"
confidence: "high|medium|low"
why_this_is_mollick_like: ""
strongest_reason_to_act: ""
strongest_reason_to_ignore: ""
related_supporting_papers: []
related_contradictory_papers: []
```

---

## 13. Triage Questions for the AI Monitor

For every new paper, answer these before recommending action:

1. What decision would this paper change?
2. What task was studied?
3. Who performed the task: students, crowd workers, professionals, experts, employees, or only models?
4. Was there a human baseline?
5. Was there an AI-only baseline?
6. Was there a human-plus-AI condition?
7. What improved: speed, quality, cost, accuracy, creativity, satisfaction, learning, or risk detection?
8. What got worse?
9. Did the paper measure error, hallucination, overreliance, bias, privacy, or security?
10. Does the result generalize to regulated enterprise settings?
11. Does the paper have a plausible workflow/control/training implication?
12. Is the result model-version dependent?
13. Could newer models have changed the conclusion?
14. Is this a benchmark-only paper? If so, what real-world task does the benchmark approximate?
15. What is the strongest critique of the paper?
16. What follow-up paper would confirm or contradict it?

---

## 14. Routing Rules for Enterprise Use

When a new paper is accepted into the monitoring pipeline, route it based on the following criteria.

| Paper type | Route to |
|---|---|
| AI improves developer productivity, code review, testing, or software agents | Engineering enablement, SDLC, technology risk. |
| AI improves writing, summarization, analyst work, or knowledge synthesis | AI integration, business enablement, training. |
| AI affects legal analysis, RAG, citation accuracy, or reasoning under authority | Legal, compliance, risk, AI governance. |
| AI shows overreliance, hallucination, cognitive debt, or automation bias | Model risk, controls, training, governance. |
| AI affects financial text analytics, valuation, research, or financial QA | Banking/markets AI leads, risk, model governance. |
| AI affects customer support, communications, persuasion, emotional support | Customer experience, conduct risk, legal, compliance. |
| AI affects education, learning, tutoring, skill formation | Training, HR, change management, AI literacy. |
| AI benchmark or frontier capability changes materially | AI strategy, architecture, evaluation team. |
| AI safety/security/prompt injection/RAG compromise | Cybersecurity, technology risk, AI platform team. |
| Regulator, BIS, FSB, Fed, OCC, SEC, FINRA, FCA, or Bank of England paper | Regulatory affairs, compliance, risk, governance. |

---

## 15. Weekly Digest Format

The AI monitor should produce a weekly digest in this structure.

```markdown
# Weekly AI Research Monitor

## 1. Executive Summary
- 3–5 bullets on what changed this week.

## 2. Papers Worth Reading
### Paper 1
- Title:
- Authors/source/date:
- One-sentence claim:
- Why it matters:
- Evidence quality:
- Enterprise implication:
- Risk/control implication:
- Recommended action:

## 3. Papers to Monitor but Not Act On
- Title + one-line reason.

## 4. Papers to Ignore
- Title + reason, especially if hype, weak evidence, benchmark-only, or irrelevant.

## 5. New Author or Research Group Alerts
- Author/group:
- Why it matters:

## 6. Contradictions or Replications
- New evidence supporting or challenging prior assumptions.

## 7. Suggested Internal Experiments
- Experiment idea:
- Business unit/workflow:
- Success metrics:
- Risk controls:

## 8. Open Questions
- What the research still does not answer.
```

---

## 16. Monthly Executive Brief Format

```markdown
# Monthly AI Research Brief

## What changed this month?

## Three papers that should affect deployment strategy

## Two papers that should affect controls or governance

## One paper that should affect AI training or change management

## One paper that suggests a near-term pilot

## One paper that suggests a deployment should be slowed or constrained

## Implications for JPMorganChase-style regulated enterprise adoption

## Recommended decisions

## Watchlist for next month
```

---

## 17. Semantic Scholar Query Strategy

The system should use three kinds of queries.

### 17.1 Exact-title queries

Use exact titles from this document first. For each, retrieve:

- Semantic Scholar paper ID
- canonical title
- authors
- year
- abstract
- DOI
- arXiv ID
- SSRN ID if available
- venue
- citation count
- influential citation count
- references
- citations
- TLDR if available
- fields of study
- open access PDF link if available

### 17.2 Author expansion queries

For high-priority authors, query new papers in the last 30, 60, and 180 days containing terms such as:

```text
generative AI
large language model
LLM
ChatGPT
GPT-4
Claude
Gemini
Copilot
RAG
retrieval augmented generation
AI assistant
AI agent
human-AI
knowledge work
productivity
field experiment
randomized
professional
legal analysis
financial text
software developers
education
learning
creativity
overreliance
automation bias
```

### 17.3 Co-citation and related-paper expansion

For each A-priority paper:

1. Retrieve top cited-by papers.
2. Retrieve references.
3. Retrieve Semantic Scholar recommendations or related papers.
4. Score each candidate using the rubric.
5. Promote only candidates that match the Mollick-like profile.

---

## 18. Deduplication and Canonicalization Rules

Many working papers appear under multiple titles or versions. The system should deduplicate aggressively.

Canonicalize using this order:

1. DOI
2. arXiv ID
3. SSRN ID
4. Semantic Scholar paper ID
5. Exact normalized title
6. Fuzzy title match plus author overlap
7. Manual review if conflicting versions appear

Normalize titles by:

- lowercasing,
- removing punctuation,
- replacing curly quotes with straight quotes,
- removing subtitles only for fuzzy matching,
- preserving full title for display,
- storing known aliases/search variants.

When two versions exist:

- Prefer peer-reviewed version if it is newer and substantively equivalent.
- Preserve working-paper version if it has richer appendices, data, or earlier public influence.
- Store both links if the paper had a major title change.

---

## 19. Negative Filters

The system should down-rank or ignore papers that have one or more of these characteristics unless they are exceptionally important:

- benchmark-only with no clear real-world task mapping,
- no human baseline where human-AI performance is the question,
- small convenience sample with broad claims,
- no measurement of quality or error,
- no operational implication,
- vendor-authored marketing paper without external validation,
- generic “AI will transform everything” essay,
- outdated model comparisons that do not generalize,
- papers that measure only user satisfaction while ignoring accuracy,
- papers that claim full automation in high-stakes settings without controls,
- papers that ignore privacy, security, compliance, or auditability in regulated use cases.

---

## 20. Positive Filters

The system should prioritize papers that have one or more of these characteristics:

- randomized controlled trial,
- field experiment,
- real employee or professional population,
- realistic task,
- comparison among human, AI-only, and human-plus-AI,
- effect sizes for speed and quality,
- measurement of error or risk,
- explicit attention to overreliance,
- generalizable workflow implication,
- clear relevance to finance, legal, compliance, risk, audit, software engineering, or operations,
- strong author/research group signal,
- replication or contradiction of an already-important paper,
- new evaluation method for real-world AI work,
- high-quality negative result.

---

## 21. JPMorganChase-Specific Interpretation Layer

For each accepted paper, the system should create a short interpretation specifically for a regulated financial institution.

The interpretation should answer:

1. Does this paper change where AI should be deployed?
2. Does it change where AI should not be deployed?
3. Does it imply a new control?
4. Does it imply a new evaluation harness?
5. Does it imply a change to training or AI literacy?
6. Does it affect legal, compliance, model risk, or cybersecurity posture?
7. Does it suggest a pilot in banking, markets, asset management, payments, operations, audit, legal, compliance, risk, or technology?
8. Does it require escalation because of safety, regulatory, or customer-impact risk?
9. Is the finding likely to survive newer model capabilities?
10. What internal data or experiment would validate the finding?

---

## 22. Recommended Internal Experiment Template

When a paper suggests an internal pilot, create an experiment proposal using this template.

```yaml
experiment_name: ""
inspired_by_paper: ""
business_area: ""
workflow: ""
participants: ""
task_description: ""
conditions:
  - human_only
  - ai_only
  - human_plus_ai
  - human_plus_ai_with_controls
metrics:
  productivity: []
  quality: []
  accuracy: []
  risk_detection: []
  customer_impact: []
  compliance: []
  employee_experience: []
controls:
  data_privacy: ""
  human_review: ""
  escalation: ""
  audit_log: ""
  model_version_tracking: ""
  prompt_and_output_retention: ""
success_criteria: []
stop_conditions: []
expected_risks: []
owner: ""
reviewers: []
```

---

## 23. Suggested System Prompt for the Research-Monitoring AI

Use or adapt the following prompt for the AI component that triages new papers.

```text
You are an AI research-monitoring analyst for enterprise AI integration at a regulated global financial institution.

Your task is to find, score, summarize, and route high-signal AI research in the style of Ethan Mollick's public research references.

Do not optimize for generic AI hype. Optimize for papers that change how organizations should deploy, govern, evaluate, train for, or constrain AI.

Prioritize:
- real work over toy tasks,
- field evidence over speculation,
- human-AI comparisons over model-only benchmarks,
- quality and risk outcomes over speed alone,
- papers that reveal boundaries, overreliance, hallucination, or failure modes,
- papers that are relevant to regulated knowledge work.

For every candidate paper, produce:
1. One-sentence claim.
2. Evidence type.
3. Population studied.
4. Task realism.
5. Human baseline, AI baseline, and human+AI condition.
6. Main effect sizes.
7. What improved.
8. What worsened.
9. Failure modes and overreliance risks.
10. Relevance to JPMorganChase-style AI integration.
11. Legal, compliance, privacy, cybersecurity, audit, and model-risk implications.
12. Strongest reason to act.
13. Strongest reason to ignore.
14. Recommended action: pilot, monitor, brief executives, send to risk/legal/engineering, or ignore.
15. Confidence score.

Be skeptical. Separate what the paper actually shows from what people might wish it showed.
```

---

## 24. Suggested Critique Prompt

Use this after a paper has been summarized.

```text
Act as a skeptical reviewer.

Find the strongest objections to this paper and its relevance to enterprise AI integration.

Check:
- whether the task is realistic,
- whether the population generalizes to professionals in a regulated financial institution,
- whether the model version is outdated,
- whether there is a human baseline,
- whether the paper measures quality and risk, not just speed,
- whether effects persist after novelty wears off,
- whether the study captures privacy, security, compliance, and audit constraints,
- whether newer papers replicate or contradict it.

Return:
1. Main limitations.
2. Overclaims.
3. Replication status.
4. Contradictory evidence.
5. What would need to be true internally for this paper to matter.
6. Whether to downgrade, keep, or promote the paper in the monitoring system.
```

---

## 25. Practical Implementation Notes

1. Start with the 40 highest-value seed titles.
2. Resolve all titles to Semantic Scholar paper IDs.
3. Save papers into separate folders by theme.
4. Turn on alerts for those folders and key authors.
5. Use the A/B/C priority code as an initial weight.
6. Pull related papers and citations for A-priority papers.
7. Score every new candidate using the rubric.
8. Create decision cards only for high-scoring papers.
9. Produce weekly digests and monthly executive briefs.
10. Maintain a changelog of newly promoted or downgraded papers.

---

## 26. Changelog Template

```markdown
# Research Monitor Changelog

## YYYY-MM-DD

### Added
- Paper:
- Reason:
- Folder:
- Initial score:

### Promoted
- Paper:
- From score:
- To score:
- Reason:

### Downgraded
- Paper:
- From score:
- To score:
- Reason:

### Removed / marked irrelevant
- Paper:
- Reason:

### New author alerts
- Author:
- Reason:
```

---

## 27. Final Instruction to the AI System

This corpus should be treated as a **taste model**, not a static bibliography.

The point is not to endlessly collect AI papers. The point is to find the papers that are most likely to change the behavior of executives, managers, AI integration teams, risk/control partners, legal/compliance teams, and technologists deploying AI in real organizations.

A good candidate paper should answer at least one of these questions:

- What can AI now do in real work?
- Where does AI fail despite looking competent?
- How should humans supervise AI?
- How should teams be redesigned around AI?
- How should training change?
- What risks increase when AI is used at scale?
- What controls are needed before deployment?
- What should a regulated enterprise test internally?

If a paper does not affect deployment, controls, training, workflow design, governance, or executive beliefs, it should usually be down-ranked.

