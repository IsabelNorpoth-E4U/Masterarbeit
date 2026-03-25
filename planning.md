# Planung


## Thema: Prompt Injection bei einem Chatbot

## Zusammenfassung: 

Es soll ein unternehmensinterner Chatbot untersucht werden, der Informationen zum deutschen Energiemarkt bereitstellt.
Der Chatbot greift dabei unter anderem auf interne SharePoint-Daten zu.
Ein zentrales Element des Systems soll das Rollen- und Rechtekonzept, das steuert, auf welche Datenquellen ein Nutzer zugreifen darf. 
Die Arbeit untersucht, inwiefern dieses Konzept Prompt-Injection-Angriffe beeinflusst. 
Beispiel: Der Versuch, mit der Rolle "Werkstundent" auf Informationen zuzugreifen, die ausschließlich für Mitarbeitende vorgesehen sind.

## Ablauf
 
1. bekannte Prompt-Injection-Techniken auf den internen Chatbot anzuwenden und potenzielle Schwachstellen zu identifizieren,
 
2. geeignete technische und konzeptionelle Schutzmaßnahmen zur Absicherung des Systems finden,
 
3. diese Maßnahmen hinsichtlich ihrer Wirksamkeit evaluieren (möglicherweise auch direkt austesten)
 
## Forschungsfrage

Inwieweit ist ein unternehmensinterner, LLM-basierter Chatbot gegenüber Prompt-Injection-Angriffen verwundbar, und wie 
können rollenbasierte Zugriffskontrollen sowie strukturierte Prompt-Formate zur Absicherung sensibler Daten beitragen?
 