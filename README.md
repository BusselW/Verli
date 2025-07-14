# Verli

## Overzicht

**Verli** is een modern, gebruiksvriendelijk verlofrooster en planningsapplicatie voor teams en organisaties. Het systeem is gebouwd met React, SharePoint-integratie en biedt uitgebreide functionaliteit voor verlofaanvragen, ziekte, compensatie-uren en zittingsvrij. De applicatie is ontworpen voor gebruik binnen organisaties met SharePoint als backend.

---

## Belangrijkste Functionaliteiten

- **Verlof aanvragen**: Medewerkers kunnen eenvoudig verlof aanvragen via een intuïtieve interface.
- **Ziek melden**: Ziekmeldingen worden direct verwerkt en zichtbaar in het rooster.
- **Compensatie-uren**: Invoer en beheer van plus- en minuren, inclusief ruildagen.
- **Zittingsvrij**: Registratie van incidentele zittingsvrije dagen.
- **Teamoverzicht**: Medewerkers zijn gegroepeerd per team, met profielkaarten en snel inzicht in beschikbaarheid.
- **Reactieve UI**: Directe feedback, tooltips, en modale vensters voor een soepele gebruikerservaring.
- **Beheerfuncties**: Specifieke rollen voor admins, functioneel beheerders en taakbeheerders.
- **SharePoint-integratie**: Data wordt opgehaald en opgeslagen in SharePoint-lijsten.

---

## Installatie & Setup

1. **Vereisten**
   - SharePoint-omgeving (voor dataopslag)
   - Webserver (IIS, Apache, of SharePoint zelf)
   - Moderne browser (Edge, Chrome, Firefox)

2. **Bestanden**
   - Plaats de inhoud van deze repository in de gewenste webmap op de server.
   - Zorg dat de mappenstructuur behouden blijft:
     - `js/` (JavaScript modules)
     - `css/` (Stijlen)
     - `icons/` (SVG en favicon)
     - `pages/` (Submodules en beheerpagina's)

3. **Configuratie**
   - Pas indien nodig `js/config/configLijst.js` aan voor SharePoint-lijstnamen en instellingen.
   - Controleer de SharePoint-permissies voor gebruikersgroepen (admin, functioneel, taakbeheer).

4. **Starten**
   - Open `verlofRooster.aspx` in de browser via de SharePoint-site of webserver.
   - Log in met je organisatieaccount.

---

## Gebruik

### Navigatie
- **Hoofdscherm**: Overzicht van alle medewerkers per team, met hun verlof, ziekte, compensatie en zittingsvrij.
- **FAB (Floating Action Button)**: Snel nieuwe aanvragen indienen (verlof, ziekte, compensatie, zittingsvrij).
- **Contextmenu**: Klik met rechts op een cel voor extra opties (bewerken, verwijderen, nieuw item).
- **Legenda**: Uitleg van kleuren en symbolen.
- **Profielkaarten**: Hover over een naam voor extra info.

### Rollen & Rechten
- **Admin**: Volledig beheer, toegang tot admincentrum.
- **Functioneel beheer**: Toegang tot beheercentrum, kan verlof en teams beheren.
- **Taakbeheer**: Toegang tot behandelcentrum, kan aanvragen verwerken.

### Veelvoorkomende Acties
- **Verlof aanvragen**: Selecteer een medewerker en periode, klik op 'Verlof aanvragen'.
- **Ziek melden**: Selecteer een dag, klik op 'Ziek melden'.
- **Compensatie-uren**: Voeg plus- of minuren toe via het contextmenu of de FAB.
- **Zittingsvrij**: Registreer incidentele zittingsvrije dagen.

---

## Projectstructuur

- `verlofRooster.aspx` — Hoofdpagina van de applicatie
- `js/core/roosterApp.js` — Hoofdlogica en React-componenten
- `js/services/` — Dataopslag, SharePoint-communicatie, permissies
- `js/ui/` — UI-componenten (modals, contextmenu, tooltips, profielkaarten)
- `js/utils/` — Hulpfuncties (datum, gebruikers, permissies)
- `css/` — Stijlen voor rooster, modals, beheer
- `icons/` — SVG-iconen voor UI en profielkaarten
- `pages/` — Submodules voor admin, beheer, instellingen

---

## Veelgestelde Vragen (FAQ)

**1. Ik zie geen medewerkers of data. Wat nu?**
> Controleer of je bent ingelogd en de juiste SharePoint-permissies hebt. Vernieuw de pagina of neem contact op met de beheerder.

**2. Hoe voeg ik een nieuw team of medewerker toe?**
> Dit kan via het beheercentrum (alleen voor beheerders).

**3. Kan ik het rooster exporteren?**
> Exportmogelijkheden zijn afhankelijk van de SharePoint-implementatie. Neem contact op met de functioneel beheerder.

**4. Ik krijg een foutmelding bij het indienen van verlof.**
> Controleer of alle verplichte velden zijn ingevuld. Bij aanhoudende problemen: neem contact op met support.

---

## Contact & Support

- **Functioneel beheer**: Neem contact op via het beheercentrum of de interne supportkanalen.
- **Technische vragen**: Zie de code in `js/services/` en `js/core/roosterApp.js` voor integratie met SharePoint en React.
- **Feedback of bugs?**: Maak een melding via de applicatie of stuur een e-mail naar het beheerteam.

---

## Licentie

Dit project is eigendom van de organisatie. Gebruik en distributie alleen met toestemming van de beheerder.