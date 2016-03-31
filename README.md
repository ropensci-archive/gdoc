# googlestuff
Mixed Google/R workflows

<https://github.com/ropensci/unconf16/issues/9>

Existing pieces of the (Google Drive) ecosystem

  * [`googlesheets`](https://github.com/jennybc/googlesheets), [`driver`](https://github.com/noamross/driver)
  * [`gauth`](https://github.com/ropenscilabs/gauth)
  * [`rchie`](https://github.com/ropensci/rchie)

Goals

  * Facilitate mixed workflows / teams
    - Noam works in R Markdown, pushed one big button, and it makes a Google Doc for his collaborator
  * Can we round trip this?
  

Possible useful small exercises

  * local Rmd --> compile to ?sthg? --> somehow attach the Rmd or the R chunks --> send to Drive --> retrieve it from Drive with a representatin of all the original stuff
  * or maybe just the one way part of that!
  * local Rmd --> compiel to ?sthg? --> local Rmd
  
Gabe Becker has sthg from an intern that does Rmd --> HTML (and maybe back again)?

The one-way design of knitr is a challenge.
