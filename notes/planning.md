# Planung

## Thema: Prompt Injection bei einem Chatbot

Untersuchung und Entwicklung von Schutzmaßnahmen gegen indirekte Prompt-Injection-Angriffe bei Tool Calling im Anwendungsfall eines unternehmensinternen Chatbot

% Entwicklung und Evaluation von Schutzmaßnahmen gegen indirekte Prompt-Injection-Angriffe bei Tool Calling in Chatbots

## Zusammenfassung

Im Rahmen dieser Arbeit werden Sicherheitsrisiken untersucht, die durch den Einsatz von Tool Calling in einem Chatbot entstehen. 
Der Fokus liegt dabei insbesondere auf der Nutzung eines Browser-Tools innerhalb des Chatbots. Als Anwendungsfall dient ein unternehmensinterner Chatbot, der 
Informationen zum deutschen Energiemarkt bereitstellt.
Zur Identifikation potenzieller Schwachstellen werden gezielt indirekte Prompt-Injection-Angriffe durchgeführt und analysiert. Aufbauend auf den 
gewonnenen Erkenntnissen werden geeignete Schutzmaßnahmen entwickelt und in den Chatbot integriert, um die identifizierten Risiken zu reduzieren.
(Abschließend werden die Angriffe erneut ausgeführt, um die Wirksamkeit der implementierten Maßnahmen praktisch zu evaluieren.)

## Ablauf
 
1. bekannte Prompt-Injection-Techniken auf den internen Chatbot anzuwenden und potenzielle Schwachstellen zu identifizieren,
 
2. geeignete technische und konzeptionelle Schutzmaßnahmen zur Absicherung des Systems finden,
 
3. diese Maßnahmen hinsichtlich ihrer Wirksamkeit evaluieren (möglicherweise auch direkt austesten)
 
## Forschungsfrage

Inwieweit ist ein unternehmensinterner, LLM-basierter Chatbot gegenüber Prompt-Injection-Angriffen verwundbar, und wie 
können rollenbasierte Zugriffskontrollen sowie strukturierte Prompt-Formate zur Absicherung sensibler Daten beitragen?
 
## Inhaltverzeichnis

1. Einleitung
   1. Problemstellung und Motivation
   2. Ziel der Arbeit
   3. Forschungsfrage
   4. Aufbau der Arbeit

2. Grundlagen 
   2.1 Large Language Models (LLMs) und Funktionsweise
   2.2 Tool Calling / Function Calling bei LLMs
   2.2.1 Sicherheitsbedrohungen bei Tool Calling
   2.3 Chatbots: Definition und Abgrenzung
   2.4 Chatbot-Architekturen (technischer Hintergrund → Angriffsflächen)
   2.5 Unternehmensinterne Chatbots: Einsatzbereich und Risiken

3. Prompt-Injection-Angriffe
   1. Definition und Einordnung von Prompt Injection -> Oder zu Grundlagen
   2. Klassifikation von Prompt-Injection-Techniken (Indirekte und Direkte Angriffe)
      1. Direkte Angriffe: Erklärung und Beispiel
      2. Indirekte Angriffe: Erklärung und Beispiel
   3. Typische Angriffsszenarien im Unternehmenskontext -> Bezug auf die Sicherheitsbedrohungen aus den Grundlagen
   4. (Beispiele bekannter Angriffe und die Auswirkungen) 

4. Analyse der Verwundbarkeit eines internen Chatbots 
   - [ ] Beschreibung des untersuchten Systems 
   - [ ] Einrichtung der Umgebung
     - [X] Installation/Implementierung des Repository 
   - [ ] Methodik zur Durchführung der Angriffe 
     - [ ] Ziel der Angriffe
     - [ ] Implementierung de Tools Calls/Browser Action
     - [ ] Aufbau lokale Website
   - [X] Durchführung der ausgewählten Prompt-Injection Angriffe 
   - [ ] Identifikation der Schwachstellen


5. Schutzmaßnahmen gegen Prompt Injection
   1. Technische Schutzmaßnahmen:
    - Input-Validierung
    - Promt-Engineering
    - Output-Überwachung

   2. Rollenasierte Zugriffkontrollen:
    - Grundprinzip
    - Umsetzung im Chatbot-Kontext

   3. Strukturierung der Prompt-Formate:
    - Trennung von System-, Entwickler- und Nutzer-Input
    - Verwendung von Templates und Constraints 

6. Evaluation der Schutzmaßnahmen
   1. Evaluationsmethodik (Welche, Funktionsweise)
   2. Testszenarien für die einzelnen Mechanismen
   3. Auswertung der Test
   4. Vergleich der Maßnahmen (Einzelne ausreichend oder alle drei verwenden?)
   5. (Diskussion der Ergebnisse)

7. Diskussion
   1. Interpretation der Ergebnisse im Kontext der Forschungsfrage
   2. Grenzen der Arbeit
   3. Abgeleitete Schutzmaßnahmen/Verbesserungen für den Chatbot
   4. Aus 3. eine konkrete Verbesserungsplan im praktischen Sinne erstellen

8. Fazit und Ausblick
   1. Zusammenfassung der wichtigsten Erkenntnisse
   2. Beantwortung der Forschungsfrage
   3. Zukünftige Forschungsansätze

9. Literaturverzeichnis

