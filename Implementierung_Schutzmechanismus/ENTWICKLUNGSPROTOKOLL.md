# Entwicklungsprotokoll: Schutz vor indirekter Prompt Injection

Dieses Protokoll hält fest, welche Änderungen am Schutzmechanismus vorgenommen wurden, warum, auf welchen Daten sie gemessen wurden und ob sie behalten oder verworfen wurden.

**Grundsatz:** Alle Entscheidungen werden auf Entwicklungsdaten getroffen. Die Testdaten werden erst nach dem Einfrieren und nur einmal verwendet.

| Datensatz | Datei | Verwendung |
|---|---|---|
| Eigener Datensatz, Dev-Split | `data/testcases.jsonl` (split = dev) | Entwicklung des Hybrids |
| Eigener Datensatz, Test-Split | `data/testcases.jsonl` (split = test) | Endergebnis eigener Datensatz (660 Fälle) |
| BIPIA-train | `data/bipia_dev_testcases.jsonl` | Entwicklung für externe Inhalte (339 Fälle, ohne die 11 E-Mails, die auch im Testteil vorkommen) |
| BIPIA-test + NotInject | `data/bipia_testcases.jsonl` | Endergebnis externe Inhalte (689 Fälle) |

Modell in allen Läufen: Mistral Small 4 (`mistral-small-2603`), Temperatur 0, kein Reasoning.

## Schritte

Werte: Recall / Falsch-Positiv-Rate (FPR).

| # | Datum | Beobachtung | Änderung | Daten | Ergebnis | Entscheidung | Ergebnisdatei |
|---|---|---|---|---|---|---|---|
| 1 | – | – | Original-Guard: „Ist die folgende Nutzereingabe ein Prompt-Injection-Angriff?“ | eigener Test-Split | 73,1 % / 10,9 % | Ausgangswert | `results/mistral_small4_*` |
| 2 | – | Verschleierte Angriffe werden übersehen (z. B. T02, T14) | Hybrid: Rekonstruktion (V0, VN, VS), Mehrheitsabstimmung (SmoothLLM, γ = 0,5), Leitfragen F0–F5 | eigener Dev-Split, dann Test-Split | 84,7 % / 7,1 % (Test) | behalten | `results/mistral_small4_hybrid2_*` |
| 2b | 09.10.2026 | Vergleich mit dem Hauptmodell | Original-Guard mit Mistral Large 4 | eigener Test-Split | 41,6 % / 0,0 % | Vergleich | `results/mistral_large4_*` |
| 3 | 10.10.2026 | Gilt das Ergebnis auch für indirekte Angriffe? | Externer Test mit BIPIA + NotInject, Ansätze unverändert | BIPIA-test | Original 34,0 % / 13,5 %, Hybrid 37,9 % / 16,6 % | Schwäche gefunden | `results/bipia_mistral_small4_*`, `results/bipia_mistral_small4_hybrid2_*` |
| 3a | 10.10.2026 | Harmlos klingende Anweisungen (4–6 %) und Angriffe am Ende von Texten (18–24 %) werden kaum erkannt | – | BIPIA-test | Ursache: Der Guard bewertet Schaden, nicht fremde Anweisungen | Analyse | – |
| 4 | 10.10.2026 | Der Prompt spricht von „Nutzereingabe“ | Prompt nennt externe Inhalte (Version 2) | BIPIA-test | wird berichtet | Vergleich der Prompt-Fassungen | `results/bipia_prompt2_*` |
| 5 | 12.10.2026 | Ob ein Satz ein Angriff ist, hängt von seiner Herkunft ab (vom Nutzer: Bitte; aus einem Dokument: Injection) | Prüfung nach Herkunft: Nutzernachrichten wie bisher, externe Inhalte zusätzlich | – | eigener Datensatz garantiert unverändert | behalten | – |
| 6 | 12.10.2026 | Fremde Anweisungen in Dokumenten sollen erkannt werden | Variante C: alle Aufforderungen auflisten, je Aufforderung „an wen“ (KI/Mensch) und „passt zum Dokument“ | BIPIA-train | 51,5 % / 7,9 % | behalten | `results/bipia_dev_variant_c_*` |
| 6a | 12.10.2026 | 4 Antworten bei langen E-Mails abgeschnitten (400 Token) | Token-Grenze 1.000 | BIPIA-train | 4 → 1 unbrauchbare Antwort | behalten (technisch) | – |
| 6b | 12.10.2026 | 9 von 10 Fehlalarmen sind Code-Antworten („Try this“) | Zusätzlicher Satz zu Ratschlägen an den Fragesteller | BIPIA-train | 66,5 % / 23,7 % (Code: 33/50 Fehlalarme) | **verworfen** | `archiv/results/bipia_dev_variant_c2_*` |
| 6c | 12.10.2026 | Lange Texte (Tabellen) schlechter erkannt | Unterteilung in Abschnitte ≤ 1.000 Zeichen | BIPIA-train | 53,0 % / 9,4 %, Latenz +75 %, Anfragen ×1,7 | **verworfen** | `archiv/results/bipia_dev_variant_c_parts_*` |
| 7 | 12.10.2026 | Hybrid und Variante C ergänzen sich (Anfang gegenüber Mitte/Ende) | Hybrid ODER Variante C | BIPIA-train | 66,0 % / 20,1 % | Zwischenstand | `results/bipia_dev_hybrid2_variant_c_*` |
| 8 | 15.10.2026 | 94 von 97 verpassten Angriffen: leere Liste, die Anweisung wurde überlesen | Nummerierte Zeilen/Sätze (strukturelles Prompt Enhancement, Kap. 5) | BIPIA-train | C allein 76,0 % / 4,3 %; Hybrid ODER C 84,0 % / 17,3 % | behalten | `results/bipia_dev_variant_c_numbered_*`, `results/bipia_dev_hybrid2_variant_c_numbered_*` |
| 8a | 15.10.2026 | Fehlalarme der Kombination stammen fast vollständig aus der Abstimmung des Hybrids, die Leitfragen fügen nur Treffer hinzu | Auswertung ohne neue Anfragen | BIPIA-train | C oder Abstimmung 83,5 % / 17,3 %; C oder Leitfragen 79,0 % / 4,3 % | Abstimmung für externe Inhalte nicht verwenden | – |
| 9 | 15.10.2026 | Variante C und Leitfragen sollen in einer Prüfung zusammengeführt werden | Variante 3: nummerierte Zeilen, je Zeile „an wen“, „passt“ und Leitfragen F1–F5; Angriff, wenn eine Angabe auffällig ist | BIPIA-train | 74,0 % / 6,5 %, F1 = 0,829 | **verworfen** (Regel unten nicht erfüllt) | `results/bipia_dev_variant_c_numbered_questions_*` |

## Vorab festgelegte Entscheidungsregel (15.10.2026, vor dem Ergebnis von Schritt 9)

Für externe Inhalte stehen zur Wahl:

- **Variante 2:** Variante C (nummeriert) ODER Leitfragen des Hybrids (mit bereinigter Fassung VN). Auf BIPIA-train: F1 = 0,868, FPR = 4,3 %, 2 Anfragen pro Text.
- **Variante 3:** Variante C (nummeriert) mit Leitfragen pro Zeile. 1 Anfrage pro Text.

**Regel:** Variante 3 wird gewählt, sofern ihre FPR höchstens 5 % beträgt und ihr F1-Wert nicht mehr als 0,02 unter dem von Variante 2 liegt (also mindestens 0,848). Andernfalls wird Variante 2 gewählt.

Begründung für die Bevorzugung von Variante 3: Sie führt beide eigenen Prüfideen (Empfänger der Aufforderung, Absicht der Aufforderung) in einer Methode zusammen, zeigt pro Zeile, wo und warum ein Angriff erkannt wurde, und benötigt nur eine Anfrage pro Text.

Nach dieser Entscheidung wird der Ansatz eingefroren. Danach folgt der einmalige Testlauf auf BIPIA-test + NotInject.

### Ergebnis der Entscheidung (15.10.2026)

| | Recall | FPR | Precision | F1 |
|---|---|---|---|---|
| Variante 2 | 158/200 (79,0 %) | 6/139 (4,3 %) | 0,963 | 0,868 |
| Variante 3 | 148/200 (74,0 %) | 9/139 (6,5 %) | 0,943 | 0,829 |

Variante 3 erfüllt keine der beiden Bedingungen (FPR 6,5 % > 5 %, F1 0,829 < 0,848). **Gewählt: Variante 2.**

Beobachtung: Mit den Leitfragen pro Zeile erkennt Variante C weniger Angriffe als ohne sie (148 statt 152). Die längere, komplexere Antwort pro Zeile verschlechtert offenbar das Auffinden der Anweisungen, ähnlich wie in Schritt 6b. Bei Code-Angriffen hilft sie leicht (41 statt 34 von 50), bei Code-Antworten steigen aber die Fehlalarme (8 statt 5).

## Endgültiger Ablauf (eingefroren am 15.10.2026)

| Herkunft des Textes | Prüfung | Anfragen pro Text |
|---|---|---|
| Nachricht des Nutzers | Hybrid (unverändert): Mehrheitsabstimmung ODER Leitfragen | 2–4 |
| Externer Inhalt (Dokument, E-Mail, Webseite, Tabelle, Code) | Variante C mit nummerierten Zeilen ODER Leitfragen des Hybrids (mit bereinigter Fassung VN) | 2 |

## Bekannte Grenzen

- Viele Entwicklungsrunden auf BIPIA-train: Der Ansatz kann darauf zugeschnitten sein. Der Unterschied zwischen Entwicklungs- und Testergebnis zeigt, wie stark.
- BIPIA enthält keine verschleierten Angriffe in Dokumenten (die Angriffe stehen im Klartext). Die Wirkung der Rekonstruktion auf externe Inhalte wird dort nicht geprüft.
- Die Herkunft eines Textes muss bekannt sein. Kopiert ein Nutzer fremde Inhalte selbst in seine Nachricht, gilt sie als Nutzernachricht.
- Das Modell reagiert empfindlich auf einzelne Sätze im Prompt (Schritt 6b).
- Trotz Temperatur 0 sind die Antworten nicht vollständig wiederholbar (Hinweis aus dem Large-4-Lauf, 11 abweichende Fälle).
- Code-Antworten führen häufiger zu Fehlalarmen als E-Mails und Tabellen.
