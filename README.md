# AWS-kurs - MOV25

**Namn:** Oscar Andersson  
**Kurs:** Amazon Web Services  
**Företag i kursuppgifterna:** Novatrix AB

## Veckouppgifter

- [Vecka 42 - EC2 och webbserver](v42/README.md)

Repo för dokumentation, kod och konfiguration under AWS-kursen.
Inga privata SSH-nycklar eller andra hemligheter får checkas in.

- [Vecka 43 – IAM och identitet](v43/README.md)

Skapa IAM-användare och grupper för drift/utveckling, koppla begränsade policyer och ge EC2-instansen `novatrix-web` läsbehörighet till en privat S3-bucket via IAM-rollen `novatrix-ec2-s3-read`. Verifiera att läsning lyckas och borttagning nekas.

- [Vecka 44 - Nätverk och säkerhet](v44/README.md)

Skapa ett eget VPC för Novatrix AB med ett publikt och två privata subnät, konfigurera routing och Internet Gateway samt säkra nätverket med Security Groups och Network ACLs. Flytta EC2-servern `novatrix-web` till det nya nätverket och verifiera att tillåten trafik fungerar medan obehörig trafik blockeras.

- [Vecka 45 – Storage och databas](v45/README.md)

Sätt upp en säker WordPress-miljö för Novatrix AB med Amazon RDS (MariaDB) för databasen, Amazon EFS för delad fillagring och Amazon S3 för säkerhetskopiering. Konfigurera privata subnät, Security Groups och IAM-behörigheter samt automatisk backup och en livscykelregel på 14 dagar. Verifiera att WordPress fungerar och att databasen och lagringen är korrekt anslutna.