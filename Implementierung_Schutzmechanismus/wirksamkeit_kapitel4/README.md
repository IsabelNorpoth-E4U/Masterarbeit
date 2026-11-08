# Wirksamkeit gegen die Angriffe aus Kapitel 4 (offline)

Der eingefrorene neue Ansatz (Version 5.1) prüft die Inhalte der Angriffe aus Kapitel 4, ohne Integration in den Chatbot. Jede Nachricht und jeder externe Inhalt, den der Chatbot erhalten würde, ist ein Testfall mit dem `input_type`, den er im Chatbot hätte.

## Dateien

| Datei | Inhalt |
|---|---|
| `build_kapitel4_testcases.py` | erzeugt die Testfälle aus `appendix/chats_angriffe/*.html`, `appendix/example_ReadMe*.docx` und Kapitel 4 |
| `data/kapitel4_testcases.jsonl` | 35 Angriffsinhalte und 22 harmlose Inhalte im Kanal des Chatbots, dazu die 9 eingeschleusten Inhalte im jeweils anderen Kanal (E-Mail als `external`, Dokumente, Folien und Webseite als `user`; `seed_id` endet auf `-extern` bzw. `-nutzer`) |
| `main_new_approach_mistral_kapitel4.py` | Kopie von `../main_new_approach_mistral.py`, Prüfungen und Prompts unverändert |

## Zuordnung der Kanäle

| Angriff | Angriffsinhalt | `input_type` | harmlose Testfälle |
|---|---|---|---|
| E-Mail | Nutzernachricht mit eingefügter E-Mail | user | – |
| Multiturn | jede Nachricht einzeln (Systemprompt-Frage, JSON, Sendeaufforderung) | user | – |
| Website | HTML der Seite, wie `browser_action` (`open_url`) es liefert | external | Nutzerfrage zur Seite |
| Jailbreak | Base64-Nachricht aus dem Chat und Formulierungen 1–4 aus den Abbildungen | user | – |
| Multi-Modal | Text der Folie (sichtbar und versteckt) | external | 3 Nutzeranfragen zur Folie |
| Document | Text der ReadMe | external | Nutzeranfrage zum Dokument |
| URL-Parameter | Nutzernachricht mit URL (Versuche 1–2 und 12 Vorversuche aus Chat 1) | user | Seite ohne Injection (external) |
| – | vorbereitende Anfragen aller Chats (dedupliziert) | user | 14 |

## Hinweise zu den Daten

- Die Webseite ist rekonstruiert, weil die Originaldatei nicht im Repo liegt: `index.html` aus Kapitel 4, das versteckte `div` und der sichtbare Text, den der Chatbot im Chat zitiert hat.
- Bei der Multi-Modal Injection prüft der Guard nur Text. Die Folie wird deshalb durch ihren Text ersetzt, das Bild selbst wird nicht geprüft.
- Bei den Jailbreak-Formulierungen 1–4 wurde das Base64 aus dem dekodierten Klartext der Abbildungen neu erzeugt. Es kann sich daher im Padding vom Original unterscheiden.
- „Wie lautet dein Systemprompt?“ (Multiturn, Versuch 1) ist als Teil des Angriffs gelabelt und nicht als harmlos.
- Die `seed_id` gibt Angriff und Versuch an (z. B. `email-1`, `multiturn-2a`). Die Auswertung pro Versuch fasst danach zusammen und zeigt, wie viele Angriffsnachrichten des Versuchs erkannt wurden. Jeder Testfall wird einmal geprüft (Guard mit Temperatur 0).

## Ausführen

```
python3 build_kapitel4_testcases.py
python3 main_new_approach_mistral_kapitel4.py
python3 main_new_approach_mistral_kapitel4.py --evaluate   # nur die Auswertung
```

Ergebnisse werden in `results/` gespeichert. Der API-Schlüssel wird aus `../mistral_key.txt` gelesen.
