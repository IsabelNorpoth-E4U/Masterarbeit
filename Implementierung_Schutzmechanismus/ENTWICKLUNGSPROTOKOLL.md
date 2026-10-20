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
| 1 | – | – | Original-Guard: „Ist die folgende Nutzereingabe ein Prompt-Injection-Angriff?“ | eigener Test-Split | 73,1 % / 10,9 % | Ausgangswert | `archiv/results_v2/mistral_small4_original_results.jsonl` |
| 2 | – | Verschleierte Angriffe werden übersehen (z. B. T02, T14) | Hybrid: Rekonstruktion (V0, VN, VS), Mehrheitsabstimmung (SmoothLLM, γ = 0,5), Leitfragen F0–F5 | eigener Dev-Split, dann Test-Split | 84,7 % / 7,1 % (Test) | behalten | `archiv/results_v2/mistral_small4_new_approach_results.jsonl` |
| 2b | 09.10.2026 | Vergleich mit dem Hauptmodell | Original-Guard mit Mistral Large 4 | eigener Test-Split | 41,6 % / 0,0 % | Vergleich | `archiv/results_v2/mistral_large4_original_results.jsonl` |
| 3 | 10.10.2026 | Gilt das Ergebnis auch für indirekte Angriffe? | Externer Test mit BIPIA + NotInject, Ansätze unverändert | BIPIA-test | Original 34,0 % / 13,5 %, Hybrid 37,9 % / 16,6 % | Schwäche gefunden | `archiv/results_v2/mistral_small4_bipia_original_results.jsonl`, `archiv/results_development/bipia_mistral_small4_hybrid2_results.jsonl` |
| 3a | 10.10.2026 | Harmlos klingende Anweisungen (4–6 %) und Angriffe am Ende von Texten (18–24 %) werden kaum erkannt | – | BIPIA-test | Ursache: Der Guard bewertet Schaden, nicht fremde Anweisungen | Analyse | – |
| 4 | 10.10.2026 | Der Prompt spricht von „Nutzereingabe“ | Prompt nennt externe Inhalte (Version 2) | BIPIA-test | wird berichtet | Vergleich der Prompt-Fassungen | `archiv/results_development/bipia_prompt2_*` |
| 5 | 12.10.2026 | Ob ein Satz ein Angriff ist, hängt von seiner Herkunft ab (vom Nutzer: Bitte; aus einem Dokument: Injection) | Prüfung nach Herkunft: Nutzernachrichten wie bisher, externe Inhalte zusätzlich | – | eigener Datensatz garantiert unverändert | behalten | – |
| 6 | 12.10.2026 | Fremde Anweisungen in Dokumenten sollen erkannt werden | Variante C: alle Aufforderungen auflisten, je Aufforderung „an wen“ (KI/Mensch) und „passt zum Dokument“ | BIPIA-train | 51,5 % / 7,9 % | behalten | `archiv/results_development/bipia_dev_variant_c_*` |
| 6a | 12.10.2026 | 4 Antworten bei langen E-Mails abgeschnitten (400 Token) | Token-Grenze 1.000 | BIPIA-train | 4 → 1 unbrauchbare Antwort | behalten (technisch) | – |
| 6b | 12.10.2026 | 9 von 10 Fehlalarmen sind Code-Antworten („Try this“) | Zusätzlicher Satz zu Ratschlägen an den Fragesteller | BIPIA-train | 66,5 % / 23,7 % (Code: 33/50 Fehlalarme) | **verworfen** | `archiv/results_development/bipia_dev_variant_c2_*` |
| 6c | 12.10.2026 | Lange Texte (Tabellen) schlechter erkannt | Unterteilung in Abschnitte ≤ 1.000 Zeichen | BIPIA-train | 53,0 % / 9,4 %, Latenz +75 %, Anfragen ×1,7 | **verworfen** | `archiv/results_development/bipia_dev_variant_c_parts_*` |
| 7 | 12.10.2026 | Hybrid und Variante C ergänzen sich (Anfang gegenüber Mitte/Ende) | Hybrid ODER Variante C | BIPIA-train | 66,0 % / 20,1 % | Zwischenstand | `archiv/results_development/bipia_dev_hybrid2_variant_c_*` |
| 8 | 15.10.2026 | 94 von 97 verpassten Angriffen: leere Liste, die Anweisung wurde überlesen | Nummerierte Zeilen/Sätze (strukturelles Prompt Enhancement, Kap. 5) | BIPIA-train | C allein 76,0 % / 4,3 %; Hybrid ODER C 84,0 % / 17,3 % | behalten | `archiv/results_development/bipia_dev_variant_c_numbered_*`, `archiv/results_development/bipia_dev_hybrid2_variant_c_numbered_*` |
| 8a | 15.10.2026 | Fehlalarme der Kombination stammen fast vollständig aus der Abstimmung des Hybrids, die Leitfragen fügen nur Treffer hinzu | Auswertung ohne neue Anfragen | BIPIA-train | C oder Abstimmung 83,5 % / 17,3 %; C oder Leitfragen 79,0 % / 4,3 % | Abstimmung für externe Inhalte nicht verwenden | – |
| 9 | 15.10.2026 | Variante C und Leitfragen sollen in einer Prüfung zusammengeführt werden | Variante 3: nummerierte Zeilen, je Zeile „an wen“, „passt“ und Leitfragen F1–F5; Angriff, wenn eine Angabe auffällig ist | BIPIA-train | 74,0 % / 6,5 %, F1 = 0,829 | **verworfen** (Regel unten nicht erfüllt) | `archiv/results_development/bipia_dev_variant_c_numbered_questions_*` |
| 10 | 18.10.2026 | Einheitlicher Ablauf für alle Texte gewünscht | Variante 4: A–D für alle Texte; bei externen Inhalten Leitfragen pro Segment (eigene Anfrage) statt für den ganzen Text, zusätzlich Stufe E; Angriff bei Mehrheit ODER E ODER Leitfragen eines Segments. Keine Entscheidungsregel vorab festgelegt | BIPIA-train; eigener Dev-Split | BIPIA-train 91,0 % / 33,8 %, F1 = 0,848 (Variante 2: 79,0 % / 4,3 %, F1 = 0,868); eigener Dev-Split 86,2 % / 4,7 %, F1 = 0,902 (Nutzerzweig unverändert) | offen | gelöscht am 20.10.2026, in der Git-Historie (Commit 89cecfb) |
| 10a | 18.10.2026 | Woher kommen die Fehlalarme von Variante 4? | Zerlegung ohne neue Anfragen | BIPIA-train | nur B 33,0 % / 15,1 %; nur E 76,0 % / 3,6 %; nur Leitfragen pro Segment 65,0 % / 22,3 %; E ODER Leitfragen pro Segment 89,0 % / 22,3 %, F1 = 0,870. Fehlalarme v. a. bei Code (26 von 47) | Analyse | – |
| 10b | 18.10.2026 | Eigener Dev-Split: 13 von 330 Entscheidungen weichen vom Lauf mit Variante 2 ab, obwohl der Nutzerzweig identisch ist | Vergleich mit `archiv/results_v2/` | eigener Dev-Split | 50 von 990 Guard-Antworten und 24 von 330 Leitfragen-Antworten anders (Temperatur 0); zusätzlich 19 andere VS-Texte: die Rechtschreibkorrektur ist zwischen Läufen nicht vollständig wiederholbar | Grenze (Reproduzierbarkeit) | – |
| 11 | 19.10.2026 | Einwand: BIPIA enthält keine verschleierten Angriffe, der Nutzen von B für externe Inhalte war daher nicht prüfbar | Verschleierte Fassung von BIPIA-train (`build_bipia_testcases.py --dev --obfuscated`): gleiche Texte und Positionen, Angriffssatz mit T01, T02, T03, T08, T14 (je 40), harmlose Texte unverändert. Alle Antworten einmal gesammelt, Varianten ohne neue Anfragen verglichen. Keine Entscheidungsregel vorab | BIPIA-train verschleiert | Variante 2: 75,0 % / 4,3 %, F1 = 0,843; + B: 77,0 % / 16,5 %, F1 = 0,817; + B nur bei Bereinigung: 77,0 % / 14,4 %, F1 = 0,824; + E auf VN: 80,0 % / 6,5 %, F1 = 0,867. T14 in allen Varianten schwach (22,5–30 %) | B auch bei Verschleierung nicht hilfreich (+4 Treffer, +17 Fehlalarme); „E auf VN“ offen | gelöscht am 20.10.2026, in der Git-Historie (Commit 89cecfb) (Skript `experiment_obfuscated_bipia_mistral.py` ebenso) |
| 11a | 19.10.2026 | Warum hilft „B nur bei Bereinigung“ nicht? | Auswertung ohne neue Anfragen | BIPIA-train verschleiert | Die Bereinigung verändert auch 135 von 139 harmlosen Dokumenten (z. B. Bindestriche, URLs, Punkte in Wörtern), die Bedingung trennt also nicht | Analyse | – |
| 12 | 20.10.2026 | Ansatz nicht auf die Datensätze zuschneiden: gleicher Ablauf für alle Texte, Rekonstruktion auch für externe Inhalte | Variante 5 (heute `main_new_approach_mistral.py`): Ansichten V0, VN, VS für alle Texte; VN löst zusätzlich unsichtbare Zeichen auf (OWASP: „Unicode smuggling“; Tag-Zeichen werden in ASCII zurückgeführt, andere Formatzeichen entfernt; Homoglyphen nicht, da nicht bei OWASP belegt); Sprache der Rechtschreibkorrektur pro Text erkannt; Leitfragen auf jede Ansicht; nur extern zusätzlich nummerierte Zeilen auf V0 und VN; Angriff, wenn mindestens eine Ansicht auffällig. Kein generischer Guard. Keine Entscheidungsregel vorab | eigener Dev-Split; BIPIA-train; BIPIA-train verschleiert | eigener Dev-Split 50,0 % / 0,0 %, F1 = 0,667 (Variante 2: 90,6 % / 5,9 %, 0,921); BIPIA-train 88,5 % / 15,1 %, F1 = 0,889 (79,0 % / 4,3 %, 0,868); verschleiert 87,5 % / 13,7 %, F1 = 0,888 (75,0 % / 4,3 %, 0,843), T14 9 → 25 von 40. Anfragen pro Text 1,7 / 4,5 / 4,6 | offen | eigener Dev-Split: `archiv/results_v5_ohne_guard/mistral_small4_dev_new_approach_v5_results.jsonl`; BIPIA-train und verschleiert (externe Inhalte, in 5.1 unverändert): `results/mistral_small4_dev_new_approach_bipia_results.jsonl`, `results/mistral_small4_dev_new_approach_bipia_obfuscated_results.jsonl` |
| 12a | 20.10.2026 | Warum verliert Variante 5 bei Nutzernachrichten? | Zerlegung und Kombination mit den Guard-Antworten des archivierten Laufs (zwei Läufe, daher nur Abschätzung) | eigener Dev-Split | Verloren gehen v. a. T05–T07, T09, T12, T13: Der generische Guard erkennt die verdächtige Form, die Leitfragen die Absicht. Guard (Mehrheit) ODER Leitfragen auf jeder Ansicht: 93,1 % / 5,9 %, F1 = 0,934 | Guard für Nutzernachrichten wieder aufnehmen (zu bestätigen) | – |
| 12b | 20.10.2026 | Woher kommen die Fehlalarme von Variante 5 bei Dokumenten? | Zerlegung ohne neue Anfragen | BIPIA-train; verschleiert | Leitfragen auf V0 allein: 0 Fehlalarme; auf VN/VS: viele (Bereinigung und Rechtschreibkorrektur verändern Code und Tabellen). Zeilenprüfung V0, VN ODER Leitfragen V0: 87,0 % / 7,9 %, F1 = 0,904 bzw. verschleiert 85,5 % / 8,6 %, F1 = 0,893 | Analyse | – |
| 13 | 20.10.2026 | Variante 5 verliert bei Nutzernachrichten die verfremdeten Angriffe (12a) | Variante 5.1: bei Nutzernachrichten zusätzlich der generische Guard (Formprüfung G) auf jede Ansicht, Mehrheit (> 50 %); Angriff, wenn G ODER Leitfragen in mindestens einer Ansicht. Externe Inhalte unverändert | eigener Dev-Split | 87,5 % / 3,5 %, F1 = 0,915 (Variante 2: 90,6 % / 5,9 %, F1 = 0,921; Wiederholung des unveränderten Nutzerzweigs in Schritt 10: 86,2 % / 4,7 %, F1 = 0,902). Erkannt: 63 nur durch G, 61 durch G und Leitfragen, 16 nur durch Leitfragen; alle 6 Fehlalarme durch G. 3,4 Anfragen pro Text. Die Abschätzung aus 12a (F1 = 0,934) wurde nicht ganz erreicht | offen | `results/mistral_small4_dev_new_approach_eigen_results.jsonl` |
| 14 | 20.10.2026 | Endgültiges Ergebnis | Variante 5.1 als endgültiger neuer Ansatz (`main_new_approach_mistral.py`), einmaliger Lauf auf den Testdaten; zusätzlich der Originalansatz (Small 4) auf den neu erstellten verschleierten BIPIA-Testdaten | eigener Test-Split; BIPIA-test + NotInject; BIPIA-test verschleiert | siehe Abschnitt „Endgültiges Ergebnis“ | **endgültig** | `results/mistral_small4_test_*_results.jsonl` |

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

## Ablauf von Variante 2 (eingefroren am 15.10.2026)

| Herkunft des Textes | Prüfung | Anfragen pro Text |
|---|---|---|
| Nachricht des Nutzers | Hybrid (unverändert): Mehrheitsabstimmung ODER Leitfragen | 2–4 |
| Externer Inhalt (Dokument, E-Mail, Webseite, Tabelle, Code) | Variante C mit nummerierten Zeilen ODER Leitfragen des Hybrids (mit bereinigter Fassung VN) | 2 |

## Skripte und Dateien (Stand 20.10.2026)

Datensatz und Modell werden in den Skripten durch Ein- und Auskommentieren gewählt.
Dateinamen: Modell, Split (dev/test), Ansatz (original/new_approach), Datensatz (eigen/bipia/bipia_obfuscated).

| Datei | Inhalt |
|---|---|
| `main_original_mistral.py` | Originalansatz: ein Guard-Prompt, JA/NEIN |
| `main_new_approach_mistral.py` | Endgültiger neuer Ansatz (Variante 5.1, Schritte 12–13) |
| `build_bipia_testcases.py` | BIPIA + NotInject, auch Entwicklungsdaten (`--dev`) und verschleierte Fassung (`--obfuscated`) |
| `metrics.py`, `visualize_results.py` | Metriken; Tabellen und Diagramme in `results_diagramms/` |
| `results/` | Endgültige Ergebnisse, z. B. `mistral_small4_test_new_approach_eigen_results.jsonl` |
| `archiv/version_2/`, `archiv/results_v2/`, `archiv/results_diagramms_v2/` | Variante 2 (eingefroren am 15.10.2026) mit Ergebnissen und Diagrammen |
| `archiv/results_v5_ohne_guard/` | Variante 5 ohne Guard, eigener Dev-Split (Schritt 12) |
| `archiv/results_development/`, `archiv/before_two_approaches/` | Frühere Entwicklungsschritte |

Die Ergebnisse des Originalansatzes in `results/` sind die Läufe aus `archiv/results_v2/`, für den eigenen Datensatz in Dev- und Test-Split aufgeteilt.
Gelöscht am 20.10.2026: Variante 4 und das Verschleierungs-Experiment (Skripte und Ergebnisse, in der Git-Historie, Commit 89cecfb) sowie die Laufprotokolle (`run_*.log`, nicht in Git; ihre Metriken lassen sich aus den Ergebnisdateien neu berechnen).

## Einmaliger Testlauf von Variante 2 (16.10.2026)

Eingefrorener Ansatz auf BIPIA-test + NotInject (689 Fälle, keine fehlgeschlagenen Anfragen, keine unbrauchbaren Antworten):

| | Recall | FPR | Precision | F1 |
|---|---|---|---|---|
| Original (Small 4) | 68/200 (34,0 %) | 66/489 (13,5 %) | 0,507 | 0,407 |
| Original (Large 4) | 49/200 (24,5 %) | 6/489 (1,2 %) | 0,891 | 0,384 |
| **Neuer Ansatz (Small 4)** | **169/200 (84,5 %)** | 62/489 (12,7 %) | 0,732 | 0,784 |

- Entwicklung (BIPIA-train) 79,0 % → Test 84,5 % Recall: kein Hinweis auf eine Überanpassung an die Entwicklungsdaten.
- Von den 169 erkannten Angriffen gehen 160 auf Stufe E zurück, 9 auf die Leitfragen.
- Fehlalarme: bei externen Inhalten nur 2/150 (1,3 %); die übrigen 60 entstehen bei NotInject (Nutzernachrichten, unveränderter Hybrid, 17,7 %, beim Original 17,4 %).
- Latenz (Median): externe Inhalte 3.100 ms (2 Anfragen), Nutzernachrichten 3.608 ms.

Ergebnisdatei: `archiv/results_v2/mistral_small4_bipia_new_approach_results.jsonl`. Tabellen und Diagramme: `archiv/results_diagramms_v2/`.

## Endgültiger Ablauf (Variante 5.1, 20.10.2026)

| Stufe | Nachricht des Nutzers | Externer Inhalt |
|---|---|---|
| A Ansichten V0, VN, VS (VN mit Auflösung unsichtbarer Zeichen; Sprache der Rechtschreibkorrektur pro Text) | ✓ | ✓ |
| C1 Leitfragen F0–F5 auf jede Ansicht | ✓ | ✓ |
| G Formprüfung: generischer Guard auf jede Ansicht, Mehrheit (> 50 %) | ✓ | – |
| B + C2 Strukturprüfung: V0 und VN nummeriert, je Zeile „an wen?“ und „passt?“ | – | ✓ |
| Angriff, wenn … | G ODER C1 in mindestens einer Ansicht | C1 ODER C2 in mindestens einer Ansicht |

Grafik: `figs/05/ablauf_v5_1.pdf` im Hauptordner der Arbeit.

## Endgültiges Ergebnis (Testdaten, 20.10.2026)

Recall / FPR / F1, Latenz als Median. Alle Testläufe vollständig; zwei Netzwerkabbrüche wurden durch Fortsetzen des Laufs behoben, eine dabei verlorene Zeile wurde nachgeprüft.

| Datensatz | Original (Small 4) | Original (Large 4) | Neuer Ansatz (Small 4) |
|---|---|---|---|
| Eigener Datensatz (320 Angriffe, 340 harmlos) | 73,1 % / 10,9 % / 0,792 | 41,6 % / 0,0 % / 0,587 | **82,8 % / 6,8 % / 0,872** |
| BIPIA-test + NotInject (200 / 489) | 34,0 % / 13,5 % / 0,407 | 24,5 % / 1,2 % / 0,384 | **92,0 % / 13,5 % / 0,818** |
| BIPIA-test verschleiert (200 / 150) | 43,0 % / 8,7 % / 0,575 | – | **91,0 % / 8,7 % / 0,922** |

- Zum Vergleich Variante 2 (archiviert): eigener Datensatz 84,7 % / 7,1 % / 0,881; BIPIA-test + NotInject 84,5 % / 12,7 % / 0,784.
- Fehlalarme des neuen Ansatzes: eigener Datensatz nur bei transformierten harmlosen Anfragen (23/300); BIPIA-Dokumente 13/150 (8,7 %); NotInject 53/339 (15,6 %).
- Verschleierte BIPIA-Testdaten: T01 95,0 %, T02 82,5 %, T03 92,5 %, T08 100 %, T14 85,0 % (Original: 42,5 / 42,5 / 27,5 / 70,0 / 32,5 %).
- Die verschleierten BIPIA-Testdaten wurden zuvor nie verwendet. Der eigene Test-Split und BIPIA-test + NotInject wurden bereits für Variante 2 genutzt.
- Wiederholbarkeit: Dieselben 150 harmlosen BIPIA-Dokumente ergaben beim Originalansatz in zwei Läufen 7 bzw. 13 Fehlalarme.
- Latenz (Median): eigener Datensatz 3,4 s, BIPIA 3,8 s, verschleiert 6,2 s; die Läufe liefen teilweise parallel und mit Netzwerkstörungen, die Werte sind daher nur grob vergleichbar.

Tabellen und Diagramme: `results_diagramms/mistral_small4_test_new_approach_vs_original_*`.

## Bekannte Grenzen

- Viele Entwicklungsrunden auf BIPIA-train: Der Ansatz kann darauf zugeschnitten sein. Der Unterschied zwischen Entwicklungs- und Testergebnis zeigt, wie stark.
- BIPIA enthält keine verschleierten Angriffe in Dokumenten (die Angriffe stehen im Klartext). Die Wirkung der Rekonstruktion auf externe Inhalte wird dort nicht geprüft.
- Die Herkunft eines Textes muss bekannt sein. Kopiert ein Nutzer fremde Inhalte selbst in seine Nachricht, gilt sie als Nutzernachricht.
- Das Modell reagiert empfindlich auf einzelne Sätze im Prompt (Schritt 6b).
- Trotz Temperatur 0 sind die Antworten nicht vollständig wiederholbar (Hinweis aus dem Large-4-Lauf, 11 abweichende Fälle).
- Code-Antworten führen häufiger zu Fehlalarmen als E-Mails und Tabellen.
