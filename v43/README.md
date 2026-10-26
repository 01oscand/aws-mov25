# Vecka 43 – IAM och identitet (Novatrix AB)

**Kurs:** Amazon Web Services (MOV25)  
**Uppgift:** 2 av 8  
**GitHub-repo:** https://github.com/01oscand/aws-mov25

## Syfte

Skapa IAM-användare och grupper för drift/utveckling, koppla begränsade policyer och ge EC2-instansen `novatrix-web` läsbehörighet till en privat S3-bucket via IAM-rollen `novatrix-ec2-s3-read`. Verifiera att läsning lyckas och borttagning nekas.

## Resurser och behörigheter (uppdatera efter genomförd labb)

| Resurs | Namn | Behörighet/syfte |
|---|---|---|
| IAM-grupp | `utveckling` | `AmazonS3ReadOnlyAccess` (läsa S3, inte skriva) |
| IAM-grupp | `drift` | `AmazonEC2FullAccess` (EC2-drift enligt kursdemonstrationen; bred tjänstbehörighet) |
| IAM-användare | `dev-erik` | Medlem i `utveckling` |
| IAM-användare | `ops-anna` | Medlem i `drift` |
| S3-bucket | `novatrix-data-01oscand-v43` | Privat, med `test.txt` |
| IAM-roll | `novatrix-ec2-s3-read` | EC2-trust + begränsad läspolicy till en enda bucket |
| EC2 | `novatrix-web` | Tilldelas rollen via instance profile |

## Policyfiler

- [`policies/trust.json`](policies/trust.json) – EC2 får anta rollen genom `sts:AssumeRole`.
- [`policies/s3-read.json`](policies/s3-read.json) – läsning av en vald bucket.

**Obs:** Gruppolicyerna är AWS-managed och behöver inte återskapas från egna JSON-filer. De ger bredare tillgång inom EC2 respektive S3 än en strikt resursavgränsad policy; EC2-rollens S3-policy är därför snävare och knuten till en enda bucket.

## Verifiering på EC2

Kör i SSH-terminalen efter att rollen har kopplats

```bash
aws --version
aws sts get-caller-identity
BUCKET="novatrix-data-01oscand-v43"
aws s3 ls "s3://$BUCKET/"
aws s3 cp "s3://$BUCKET/test.txt" -
aws s3 rm "s3://$BUCKET/test.txt"
```

- IAM-rollens ARN syns, `ls` och `cp` fungerar. `rm` ska ge `AccessDenied`. Ett nekande är positivt bevis för att raderingsbehörighet saknas. Kör inte `aws configure` med långlivade åtkomstnycklar på instansen.

## Faktiska testresultat

- Bucketnamn: **novatrix-data-01oscand-v43**
- Roll syns i `aws sts get-caller-identity`: ja
- S3-listning: lyckades
- Läsning `test.txt`: lyckades
- Radering: AccessDenied
- Inloggning som `dev-erik`: läsning lyckades / uppladdning nekades


