# share-desk-gpt

Monialustainen asennus- ja CLI-perusta **share-desk-gpt**-projektille.

> **Nykytila:** julkisessa repositoriossa ei vielä ole varsinaista sovelluksen käynnistyspistettä. Tämä versio rakentaa siksi vain asennus- ja runtime-kerroksen keksimättä puuttuvia ominaisuuksia.

## Toiminta

Asentaja tunnistaa `PATH`-ympäristön, tarkistaa Node.js:n/npm:n/npx:n, asentaa Node.js:n vain tarvittaessa, tarkistaa SHA-256-tiivisteen ja luo komennon `share-desk-gpt` käyttäjän PATHiin.

`npx`:ää ei asenneta erikseen, koska se kuuluu npm:ään (`npx`/`npm exec`).

NixOS:ssa käytetään Nixiä. SteamOS:ssa käytetään käyttäjäkohtaista asennusta, jotta muuttumatonta järjestelmäpohjaa ei muuteta.

## Asennus

Linux:

```bash
bash scripts/install.sh
```

Järjestelmän laajuisena:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Tarkistus:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Alustat

Windows x64/ARM64 ja Linux x64/ARM64/ARMv7. ARMv7 käyttää Node.js 22:ta, koska Node.js 24 ei enää julkaise nykyistä Linux ARMv7 -binaaria.

## Vakaus

Käyttäjäasennus on oletus: ei root-/ylläpitäjäoikeuksia, PATHia ei ylikirjoiteta ja poisto on helppo. NixOS ja SteamOS käsitellään erikseen niiden järjestelmänhallintamallin vuoksi.

## Nykyinen rajoitus

CLI näyttää tarkoituksella vain diagnostiikan ja todellisen tilan, kunnes julkinen repository sisältää varsinaisen share-desk-gpt-entrypointin.
