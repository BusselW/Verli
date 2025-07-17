We are editing the 'beheerCentrumN.aspx' page. This file contains a compilation of 'things to change'. 

# All tabs:
  a. Tabs that have a 'Kleur' need to visually display their hex value in a small box in front of the hexcolor [Verlofredenen, [Dagen Indicators]
  b. Tabs that have a 'Username', 'Gebruikersnaam', 'TeamleiderID', 'MedewerkerID' need to use subtle tags for these values. The formatting of those fields is domain\username but just enclose the whole thing in a single tag.
  c. Boolean values are handled with sliders.
  d. date+time values are displayed in a human readable format, e.g. dd-mm-yyyy hh:mm. It's also alright to simply split the values to dd-mm-yyyy and hh:mm in seperate columns. As long as the actual data is merged back together into a single date + time value.
  e. date values (no time) are also shown in dd-mm-yyyy, [Medewerkers], [Compensatie Uren], [Verlof], [Uren per Week],
  f. Tabs with a 'Status' column dispay these in green/orange/red based on their contents.
  g. E-mail columns are clickable and open the default e-mail application through mailto:{$Email}

   # Modal
  Before we continue, it's important you:
    a. check if data is correctly being loadded by all tabs. Analyse the #configLijst.js file to do so. what isn't working already is:[Keuzelijst functies], [Incidenteel Zitting Vrij], [Status Opties], [Mededeling], [ZittingsVrijOpmaak]

  If you any list definition cause it's not present in #configLijst.js, let me know.
