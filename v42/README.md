# V42 - Uppgift 1: Compute och kom igång

## Syfte

En enkel webbplats för Novatrix AB driftsätts på en EC2-instans i AWS.

## Konfiguration

- **Region:** eu-north-1 (Stockholm)
- **Instansnamn:** novatrix-web
- **Operativsystem:** Amazon Linux 2023
- **Instanstyp:** t3.micro
- **Security Group:** novatrix-web-sg
- **Ingress SSH:** TCP 22, My IP
- **Ingress HTTP:** TCP 80, 0.0.0.0/0
- **Webbserver:** Apache (`httpd`)
- **Webbfil:** `v42/index.html` -> `/var/www/html/index.html`
- **Budget:** 10 USD/månad, larm för faktisk och prognostiserad kostnad

## Installation och verifiering (på EC2)

```bash
sudo dnf update -y
sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd --no-pager
```

Hämta den publicerade HTML-filen från det publika GitHub-repot när `index.html` pushats:

```bash
sudo curl -fL 'https://raw.githubusercontent.com/01oscand/aws-mov25/main/v42/index.html' -o /var/www/html/index.html
curl -I http://localhost
```

**Publik IP vid verifiering:** 56.228.29.59
**Resultat vid HTTP-test:** HTTP/1.1 200 OK 
**Datum:** 19/10/2026

## Dokumentation

PDF-inlämningen har skärmbilder på instans, säkerhetsgrupp, SSH, Apache, webbplats, GitHub och budgetlarm.
