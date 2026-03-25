**ACHTUNG** | **ACHTUNG** | **ACHTUNG**

Diese Version ist alt. Mit Stand Mai 2025 verwenden Sie bitte folgende LaTeX-Vorlage: 

=> https://github.com/awkologist/HSMW-Template-BioChem-Group

**ACHTUNG** | **ACHTUNG** | **ACHTUNG**

---

# LatexThesis
Vorlage für Protokolle, Belege und Abschlussarbeiten

## What's new?
Auch DOIs werden jetzt im Literaturverzeichnis dargestellt.

In einer älteren Version konnte es zu dem LaTeX Error "File 'scrpage2.sty' not found." kommen. Infolgedessen wurde keine PDF-Datei erzeugt. Das *scrpage2*-Paket ist für die Beschriftung der Seitenköpfe zuständig und veraltet. Ich habe es durch das Paket *scrlayer-scrpage* in der Datei *hsmw-class.cls* ersetzt.

## Tipps

### Buchseiten in Literaturverzeichnis
Wenn Sie die das BibTex-Format *@book* verwenden, dann wird der Tag *pages* ignoriert:

- Wünschiers, R (2016). Wiley-Schnellkurs Bioinformatik – Datenmassen Richtig Fassen.
In: Wiley-VCH, ISBN: 978-3-527-53040-3.

Bei dem Format *@inbook* werden die Seiten dagegen angezeigt. Sie sollten mit dem Tag *chapter* auch den Namen des Kapitels angeben:

- Wünschiers, R (2016) Wiley-Schnellkurs Bioinformatik – Datenmassen richtig fassen.
Kap. *Es allen zeigen*: S. 221–241. Wiley-VCH. ISBN: 978-3-527-53040-3.

