# Planung

## Thema: Prompt Injection bei einem Chatbot

Untersuchung und Entwicklung von Schutzmaßnahmen gegen indirekte Prompt-Injection-Angriffe bei Tool Calling im Anwendungsfall eines unternehmensinternen Chatbot

## Zusammenfassung

Im Rahmen dieser Arbeit werden Sicherheitsrisiken untersucht, die durch den Einsatz von Tool Calling in einem Chatbot entstehen. 
Der Fokus liegt dabei insbesondere auf der Nutzung eines Browser-Tools innerhalb des Chatbots. Als Anwendungsfall dient ein unternehmensinterner Chatbot, der 
Informationen zum deutschen Energiemarkt bereitstellt.
Zur Identifikation potenzieller Schwachstellen werden gezielt indirekte Prompt-Injection-Angriffe durchgeführt und analysiert. Aufbauend auf den 
gewonnenen Erkenntnissen werden geeignete Schutzmaßnahmen entwickelt und in den Chatbot integriert, um die identifizierten Risiken zu reduzieren.
(Abschließend werden die Angriffe erneut ausgeführt, um die Wirksamkeit der implementierten Maßnahmen praktisch zu evaluieren.)


## Forschungsfrage

Inwieweit ist ein unternehmensinterner, LLM-basierter Chatbot gegenüber Prompt-Injection-Angriffen verwundbar, und wie können 
diese "versteckten" Anweisungen aus großen Prompts extrahiert werden?


## Inhaltverzeichnis

1. Einleitung
   - [ ] 1.1 Problemstellung und Motivation
   - [ ] 1.2 Ziel der Arbeit
   - [ ] 1.3 Forschungsfrage
   - [ ] 1.4 Aufbau der Arbeit

2. Grundlagen 
   - [ ] 2.1 Large Language Models (LLMs) und Funktionsweise
   - [ ] 2.2 Tool Calling / Function Calling bei LLMs
     - [ ] 2.2.1 Sicherheitsbedrohungen bei Tool Calling
   - [ ] 2.3 Chatbots: Definition und Abgrenzung
   - [ ] 2.4 Chatbot-Architekturen (technischer Hintergrund → Angriffsflächen)
   - [ ] 2.5 Unternehmensinterne Chatbots: Einsatzbereich und Risiken

3. Prompt-Injection-Angriffe
   - [ ] 3.1 Definition und Einordnung von Prompt Injection -> Oder zu Grundlagen
   - [ ] 3.2 Klassifikation von Prompt-Injection-Techniken (Indirekte und Direkte Angriffe)
      - [ ] 3.2.1 Direkte Angriffe: Erklärung und Beispiel
      - [ ] 3.2.2 Indirekte Angriffe: Erklärung und Beispiel
   - [ ] 3.3 Typische Angriffsszenarien im Unternehmenskontext -> Bezug auf die Sicherheitsbedrohungen aus den Grundlagen
   - [ ] 3.4 (Beispiele bekannter Angriffe und die Auswirkungen) 

4. Analyse der Verwundbarkeit eines internen Chatbots
   - [ ] Überarbeitet
   - [ ] Probegelesen
   - [ ] Alle Quellen/Informationen hinzugefügt
      - [X] 4.1 Beschreibung des untersuchten Systems 
      - [X] 4.2 Einrichtung der Umgebung
        - [X] 4.2.1 Installation/Implementierung des Repository 
      - [X] 4.3 Methodik zur Durchführung der Angriffe 
        - [X] 4.3.1 Ziel der Angriffe
        - [X] 4.3.2 Implementierung de Tools Calls/Browser Action
        - [X] 4.3.3 Aufbau lokale Website
      - [X] 4.4 Durchführung der ausgewählten Prompt-Injection Angriffe 
      - [X] 4.4.1 Identifikation der Schwachstellen


5. Schutzmaßnahmen gegen Prompt Injection
   - [ ] 5.1 Einordnung der Kategorien
   - [ ] 5.2 Nennung von zwei bis drei Maßnahmen pro Kategorie + Einordnung auf das Anwendungsbeispiel des Chatbots
     
6. Evaluation der Schutzmaßnahmen
   - [ ] 6.1 Evaluationsmethodik (Welche, Funktionsweise)
   - [ ] 6.2 Auswertung der Test
   - [ ] 6.3 Vergleich der Maßnahmen (Einzelne ausreichend oder alle drei verwenden?)
   - [ ] 6.4 Umsetzung einer Maßnahme am Chatbot
   - [ ] 6.5 Abgrenzung zu bisherigen Methoden
   - [ ] 6.6 Analyse der Ergebnisse anhand Metrik

7. Diskussion
   - [ ] 7.1 Interpretation der Ergebnisse im Kontext der Forschungsfrage
   - [ ] 7.2 Grenzen der Arbeit
   - [ ] 7.3 Abgeleitete Schutzmaßnahmen/Verbesserungen für den Chatbot
   - [ ] 7.4 Aus 3. eine konkrete Verbesserungsplan im praktischen Sinne erstellen

8. Fazit und Ausblick
   - [ ] 8.1 Zusammenfassung der wichtigsten Erkenntnisse
   - [ ] 8.2 Beantwortung der Forschungsfrage
   - [ ] 8.3 Zukünftige Forschungsansätze